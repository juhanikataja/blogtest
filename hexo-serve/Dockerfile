FROM nginx:1.14.2-alpine

# support running as arbitrary user which belogs to the root group 
RUN chgrp --recursive 0 /var/cache/nginx /var/run /var/log/nginx
RUN chmod -R g+rwX /var/cache/nginx /var/run /var/log/nginx


# comment user directive as master process is run as user in OpenShift anyhow RUN sed -i.bak 's/^user/#user/' /etc/nginx/nginx.conf
RUN sed -i.bak 's/listen\(.*\)80;/listen 8080;/' /etc/nginx/conf.d/default.conf
# users are not allowed to listen on priviliged ports 
EXPOSE 8080

RUN addgroup nginx root

RUN rm -rf /usr/share/nginx/html && mkdir -p /usr/share/nginx/html

COPY public/ /usr/share/nginx/html

USER nginx
