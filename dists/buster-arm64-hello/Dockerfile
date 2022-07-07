# Base it on Debian 10
#FROM debian:buster
#FROM i386/debian:buster
#FROM kohaaloha/raspbian:buster-slim
FROM arm64v8/debian:buster

# File Author / Maintainer
LABEL maintainer="mtj@kohaaloha.com"

ENV PATH /usr/bin:/bin:/usr/sbin:/sbin
ENV DEBIAN_FRONTEND noninteractive

# Set suitable debian sources
##RUN echo "deb [trusted=yes] http://archive.raspbian.org/raspbian buster  main contrib non-free rpi" >>  /etc/apt/sources.list

#ENV REFRESHED_AT 2019-10-01-0

# Install apache2 and testting deps
# netcat: used for checking the DB is up
RUN apt-get -y update \
    && apt-get -y install \
      wget \
      figlet \
   && rm -rf /var/cache/apt/archives/* \
   && rm -rf /var/lib/apt/lists/*

# Set locales
#RUN    echo "en_US.UTF-8 UTF-8" >> /etc/locale.gen \
#    && locale-gen \
#    && dpkg-reconfigure locales \
#    && /usr/sbin/update-locale LANG=en_US.UTF-8

#ENV LANGUAGE en_US.UTF-8
#ENV LANG en_US.UTF-8
#ENV LC_ALL en_US.UTF-8
#ENV LC_CTYPE en_US.UTF-8

#VOLUME /kohadevbox/koha

RUN figlet 11

COPY files/payload-hello.sh /kohadevbox
#COPY files/templates /kohadevbox/templates
#COPY env/defaults.env /kohadevbox/templates/defaults.env

#CMD ["/bin/bash", "/kohadevbox/run.sh"]
CMD ["/bin/bash", "/kohadevbox/payload-hello.sh"]

#EXPOSE 8080 8081
