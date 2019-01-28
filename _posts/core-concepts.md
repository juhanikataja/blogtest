# Simplified architecture of the rahti okd cluster

The [OKD](https://www.okd.io) is a distribution of kubernetes (The Origin
Community Distribution of Kubernetes that powers RedHat OpenShift). Because OKD
is contained in RedHat's OpenShift, we might speak about Openshift and OKD
interchangeably, but strictly speaking they are different platforms. Sometimes,
if we get wildly colloquial, we might even abandon camel casing and say
'openshift'!

Pretty good working definition of openshift is:
>Openshift is a multi-tenant container orchestration and management tool.

Basically, what openshift does for you is that it

1. Runs your container images
2. Stores your container images
3. Builds your container images
4. Follows your container images
5. Routes network traffic to your container images

Openshift is managed using web dashboard or, better yet, command line tool called
`oc`. If you've seen kuberentes, well `oc` is the openshift variant of `kubectl`.
The web dashboard of rahti countainer cluster is located at https://rahti.csc.fi/.

For storing your container images, rahti okd cluster comes along with an
internal docker registry that is also managed using a web console or a with the
docker's CLI tool `docker`. The registry integrated in rahti is located at http://rahti-console.csc.fi/.

If you want to treat this document as a tutorial. You should play log in to 

* rahti and 
* rahti-console and
* install `oc` tool and
* log in to rahti with `oc`.

# Simplest possible app in OKD

Suppose that we have a openshift namespace `staticserve`. We want run image in the local docker registry `docker-registry.default.svc:5000/staticserve/serveimage:latest` and we'd like to expose its port 8080 at `ourservice-staticserve.rahtiapp.fi`.

In simplest possible case we need
1. Pod that runs the container
2. Service that exposes the pod internally and gives it a predictable name to refer
3. Route that will expose the Service in 2. to outer world and redirects `outerservice-staticserve.rahtiapp.fi` to the given service object.

So lets go ahead and define the pod, service and the route manually.

**Handmade pod**

Pods are objects that keep given number of containers running. If a container dies for some reason, pod will automatically try to run it again.

In our case, the pod will run the container image with the web server.

*`pod.yaml`:*

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: pod
  labels:
    app: blogtest
    pool: servepod
spec:
  containers:
  - name: serve-cont
    image: "docker-registry.default.svc:5000/staticserve/serveimage:latest"
```

* `spec.containers[0].image` is the image name that runs inside the container 0 inside the pod. Typically this is populated by openshift deployments or statefulsets.
* `metadata.name` is the name so that the pod can be referred using, e.g., `oc`:

    ```bash
    oc get pods pod
    ```

  Typically this is populated by openshift when pod is created automatically.
* `metadata.labels.pool` is just an arbitrary label so that the pod can be referred by, e.g., *services*.

*InitContainer* is a container in a pod that is run to completion before the
main containers are started. Data from init containers are most easily transfered to
the main container using volume mounts

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: pod
  labels:
    app: blogtest
    pool: servepod
spec:
  volumes: 
  - name: sharevol
    emptyDir: {}
  initContainers:
  - name: perlhelper
    image: perl
    command:
    - sh
    - -c
    - >
      echo Hello from perl helper > /datavol/index.html
    volumeMounts:
    - mountPath: /datavol
      name: sharevol
  containers:
  - name: serve-cont
    image: docker-registry.default.svc:5000/openshift/httpd
    volumeMounts:
    - mountPath: /var/www/html
      name: sharevol
```

Here we run init container from image perl which echoes stuff to file
`index.html` on the shared volume. 

The shared volume is defined in `spec.volumes` and "mounted" in
`spec.initContainers.volumeMounts` and `spec.containers.volumeMounts`.

*Jobs*

One can also do a run-to-completion pods called 'jobs':

```yaml
apiVersion: batch/v1
kind: Job
metadata:
  name: pi
spec:
  template:
    spec:
      volumes:
      - name: smalldisk-vol
        emptyDir: {}
      containers:
      - name: pi
        image: perl
        command:
        - sh
        - -c
        - >
          echo helloing so much here! Lets hello from /mountdata/hello.txt too: &&
          echo hello to share volume too >> /mountdata/hello-main.txt &&
          cat /mountdata/hello.txt
        volumeMounts: 
        - mountPath: /mountdata
          name: smalldisk-vol
      restartPolicy: Never
      initContainers:
      - name: init-pi
        image: perl
        command: 
        - sh
        - -c
        - >
          echo this hello is from the initcontainer >> /mountdata/hello.txt
        volumeMounts: 
        - mountPath: /mountdata
          name: smalldisk-vol
  backoffLimit: 4
```

**Handmade service**

*`service.yaml`:*
```yaml
apiVersion: v1
kind: Service
metadata:
  name: serve
  labels:
    app: blogtest
spec:
  ports:
  - name: 8080-tcp
    port: 8080
    protocol: TCP
  selector:
    pool: pod
```

* This will redirect TCP traffic internally to pods with label "pool=servepod".

**Handmade route**

*`route.yaml`:*
```yaml
apiVersion: v1
kind: Route
metadata:
  labels:
    app: blogtest
  name: servepod
spec:
  host: ourservice-staticserve.rahtiapp.fi
  to:
    kind: Service
    name: serve
    weight: 100
```

This route will redirect traffic from internet to service in the cluster having
with `metadata.name` being `spec.to.name`.

* Currently `spec.to.kind` must be `Service`.
* If the service `spec.to.name` has multiple ports defined then it might make sense to define `spec.port.targetport`

----

Lets put up a simple mnemonic to remember all this:

>You binary is in an image in the container started by pod named by the service announced by the route.

----

So now we have a pod, a service and a route. But what happens if image is updated? For that, we can use...

**Handmade DeploymentConfig**

DeploymentConfigs actually do more than just look at updating images:

* They start and keep running a given number of pods
* They do rolling updates if images change

*`deploymentconfig.yaml`*
```yaml
apiVersion: v1
kind: DeploymentCOnfig
metadata:
  labels:
    app: blogtest
  name: blogdeployment
spec:  
  replicas: 1
  selector:
    app: blogtest
    deploymentconfig: blogdeployment
  strategy:
    activeDeadlineSeconds: 21600
    type: Rolling
  template: # This is the most interesting part!
    metadata:
      labels:
        app: blogtest
        deploymentconfig: blogdeployment
    spec:
      containers:
      - name: serve-cont
        image: "serveimagestream:latest"
  triggers:
  - type: ConfigChange # re-deploy if config is changed
  - imageChangeParams: # re-deploy if imagestream "serveimagestream:latest" triggers
      automatic: true
      containerNames:
      - serve-cont
      from:
        name: serveimagestream:latest
    type: ImageChange
```

*Hold on*! What is this imagestream object?

***Excursion to ImageStream objects***

ImageStreams simplify image names and get triggered by a BuildConfig if new
images are being uploaded to the registry. In the case where a new image is
uploaded, it can trigger its listeners to act. In the case of our
DeploymentConfig, action would be to do a rolling update for the pods that it is
meant to deploy.

A simple ImageStream object looks like this:

*`imagestream.yaml`*
```yaml
apiVersion: image.openshift.io/v1
kind: ImageStream
metadata:
  labels:
    app: blogtest
  name: serveimagestream
spec:
  lookupPolicy:
    local: false
```

## A 1-minute introduction to yaml files for humans

YAML is used to describe key-value maps and arrays. You can recognize YAML file from `.yml` or `.yaml` file suffix.

A YAML dataset can be

1. Value

    ```yaml
    value
    ```

2. Array
    ```yaml
    - value 1
    - value 2
    - value 3
    ```
  or
    ```yaml
    [value 1, value 2, value 3]
    ```

3. Unordered map
    ```yaml
    key: value
    another_key: another value
    ```
  or
    ```yaml
    key:
      value
    another_key:
      another value
    ```

Now the real kicker is: value can be a YAML dataset!

```yaml
key:
  - value 1
  - value 2
  another key:
    yet another key: value of yak
  another keys lost sibling:
    - more values
  this key has one value which is array too:
  - so indentation is not necessary here since keys often contain arrays
```

You can do multiline values:

```yaml
key: >
  Here's a value that is written over multiple lines
  but is actually still considered a single line until now.

  Placing double newline here will result in newline in the actual data.
```

Or if you want *verbatim* kind of style:
```yaml
key: |
  Now the each
  newline is
  treated as such so
```

For more information, take a look at https://yaml.org/.

