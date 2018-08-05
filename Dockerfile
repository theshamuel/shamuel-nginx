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
     curl -Lko /tmp/lego.tar.gz https://github.com/xenolf/lego/releases/download/v1.0.1/lego_v1.0.1_linux_386.tar.gz && \
     tar -zxf /tmp/lego.tar.gz -C /usr/bin/ && \
     chown root /usr/bin/lego && \
     chmod +x /usr/bin/lego && \
     chgrp root /usr/bin/lego && \
     chown root /usr/bin/lego && \
     rm -rf /etc/nginx/conf.d/* && \
     chmod +x /entrypoint.sh

CMD ["/entrypoint.sh"]

