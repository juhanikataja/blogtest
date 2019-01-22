FROM node:8.15.0-jessie

WORKDIR /build

RUN npm install -g hexo-cli
RUN hexo init /build/hexo
WORKDIR /build/hexo
RUN npm install
RUN rm -rf source
