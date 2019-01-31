# CLI cheat sheet

**Abbreviations**

Object types have abbreviations that are recognized on CLI:
|Abbreviation |Meaning|
|-----:|:-------|
|`is`|`ImageStream`|
|`dc`|`DeploymentConfig`|
|`svc`|`Service`|
|`bc`|`BuildConfig`|
|`rc`|`ReplicationController`|
|`pvc`|`PersistentVolumeClaim`|

**Basic usage:**

```bash
$ oc <subcommand> <--flags>
```

**Examples**

Get all pods:

```bash
$ oc get pods
```

Get all pods that have key-value -pair `app: myapp` in `metadata.labels`:

```bash
$ oc get pods --selector app=myapp
```

Output specifications of pod `mypod`

```bash
$ oc get pod mypod -o yaml
```

**Other useful commands**

* `oc create` creates an object. Example: `oc create -f file.yaml`.
* `oc replace` replaces object. Example: `oc replace -f file.yaml`
* `oc delete` deletes object in openshit. Example: `oc delete rc myreplicationcontroller`
* `oc apply` modifies object according to input. Example `oc apply -f file.yaml`
* `oc explain` prints out API documentation on. Example: `oc explain dc.spec`.
