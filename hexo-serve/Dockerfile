FROM hexo-initial:latest

ARG GIT_SOURCE_REPOSITORY=https://github.com/juhanikataja/blogtest
ARG GIT_CONTENT_BRANCH=content

WORKDIR /build/hexo
RUN git clone ${GIT_SOURCE_REPOSITORY} --branch ${GIT_CONTENT_BRANCH} source

RUN hexo generate

FROM nginx:1.14.2-alpine

RUN rm -rf /usr/share/nginx/html && mkdir -p /usr/share/nginx/html
COPY --from=0 /build/hexo/public/ /usr/share/nginx/html
