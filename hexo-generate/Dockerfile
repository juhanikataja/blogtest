FROM jkataja-training/hexo-initial
ARG GIT_SOURCE_REPOSITORY=https://github.com/juhanikataja/blogtest
ARG GIT_CONTENT_BRANCH=content

WORKDIR /build/hexo
RUN git clone ${GIT_SOURCE_REPOSITORY} --branch ${GIT_CONTENT_BRANCH} source

RUN hexo generate
