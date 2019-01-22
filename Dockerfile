FROM node:8.15.0-jessie as builder

ARG CONTENT_SOURCE

RUN mkdir -p build
WORKDIR build

RUN npm install -g hexo-cli
RUN hexo init build/hexo
WORKDIR build/hexo
RUN npm install
RUN rm -rf source

RUN git clone https://github.com/juhanikataja/blogtest --branch content source

RUN hexo generate

FROM nginx:1.14.2-alpine

RUN rm -rf /usr/share/nginx/html && mkdir -p /usr/share/nginx/html
COPY --from=builder /build/build/hexo/public/ /usr/share/nginx/html
