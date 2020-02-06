FROM nginx:1.11
MAINTAINER Ossi Rajuvaara <ossi@robocorp.com>

COPY nginx.conf /etc/nginx/

COPY entrypoint.sh /
RUN chmod +x /entrypoint.sh
ENTRYPOINT ["/entrypoint.sh"]
