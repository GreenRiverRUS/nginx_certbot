FROM nginx:stable-alpine

RUN apk add -u certbot openssl vim

RUN rm -rf /etc/nginx/*
COPY nginx /etc/nginx
COPY scripts/* /bin/

ARG site
COPY $site /etc/nginx/sites/

VOLUME /etc/letsencrypt
CMD /bin/run.sh
