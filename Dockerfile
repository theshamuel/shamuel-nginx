FROM nginx:1.13-alpine

LABEL maintainer="Alex Gladkikh <theshamuel@gmail.com>"

ADD conf/nginx.conf /etc/nginx/nginx.conf
ADD conf/blog.shamuel.com.conf /etc/nginx/blog.shamuel.com.conf
ADD conf/shamuel.com.conf /etc/nginx/shamuel.com.conf

ADD etc/entrypoint.sh /entrypoint.sh

RUN apk add -U openssl && \
     apk add -U ca-certificates && \
     apk add -U curl && \
     apk add -U libc-dev && \
     curl -sL https://github.com/xenolf/lego/releases/download/v1.0.1/lego_v1.0.1_linux_amd64.tar.gz --output /lego.tar.gz && \
     tar -xzf /lego.tar.gz -C /usr/bin/ && \
     rm -rf /etc/nginx/conf.d/* && \
     chmod +x /entrypoint.sh

CMD ["/entrypoint.sh"]
