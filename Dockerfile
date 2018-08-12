FROM debian:latest

VOLUME /var/lib/schema
VOLUME /var/lib/output

ADD .output/presilo /usr/local/bin/

ENTRYPOINT ["/usr/local/bin/presilo"]