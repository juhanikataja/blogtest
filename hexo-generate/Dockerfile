FROM hexo-initial

WORKDIR /build/hexo
RUN mkdir -p source
COPY _posts source/_posts
RUN mv source/_posts/img source/img

RUN hexo generate
