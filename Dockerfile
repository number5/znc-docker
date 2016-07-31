FROM alpine

ENV ZNC_VERSION 1.6.3
ENV ZNCSTRAP_BRANCH dev

RUN apk update && \
    apk add -t .build_deps build-base znc-dev openssl-dev && \
    apk add znc znc-extra znc-modpython znc-modperl
RUN apk add -U sudo bash git


ADD identserv.cpp /identserv.cpp
RUN chmod 644 /identserv.cpp
RUN /usr/bin/znc-buildmod /identserv.cpp
RUN mv /identserv.so /usr/lib/znc
RUN apk del .build_deps

RUN git clone -b ${ZNCSTRAP_BRANCH} https://github.com/ProjectFirrre/zncstrap/ /zncstrap && \
    rm -Rf /usr/share/znc/webskins && \
    rm -Rf /usr/share/znc/modules && \
    mv /zncstrap/webskins /usr/share/znc/ && \
    mv /zncstrap/modules /usr/share/znc/

ADD docker-entrypoint.sh /entrypoint.sh
ADD znc.conf.default /znc.conf.default
RUN chmod +x /entrypoint.sh
RUN chmod 644 /znc.conf.default

VOLUME /znc-data

# 11300 is our identserver, map it to 113 on the host
EXPOSE 33033 11300
ENTRYPOINT ["/entrypoint.sh"]
CMD [""]
