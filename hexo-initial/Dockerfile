FROM node:8.15.0-jessie

WORKDIR /build

RUN npm install -g hexo-cli
RUN hexo init /build/hexo
WORKDIR /build/hexo
RUN yarn add hexo-filter-mermaid-diagrams
COPY _config.yml /build/hexo/
COPY after-footer.ejs /build/hexo/themes/landscape/layout/
RUN npm install
RUN rm -rf source
