FROM node:8.15.0-jessie

WORKDIR /build

RUN npm install -g hexo-cli
RUN hexo init /build/hexo
WORKDIR /build/hexo
COPY hexo-initial/_config.yml /build/hexo/
# RUN cat /build/after-footer.ejs >> /build/hexo/themes/landscape/layout/_partial/after-footer.ejs
RUN npm install
RUN rm -rf source
RUN git clone https://github.com/juhanikataja/hexo-theme-purely themes/purely
