FROM centos/nodejs-6-centos7 as builder

ARG CONTENT_SOURCE

RUN mkdir -p /build
WORKDIR /build

RUN npm install -g hexo
RUN hexo init /build/hexo
WORKDIR /build/hexo

