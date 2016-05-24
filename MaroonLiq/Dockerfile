FROM ubuntu:trusty


MAINTAINER Eric Weber webere@lafayette.edu

RUN apt-get -q update && \
    apt-get -q -y install liquidsoap supervisor && \
    apt-get clean

ADD ./config.liq /config/config.liq
ADD ./playlist/ /playlist/
RUN chmod a+x /config/config.liq
ADD ./supervisor.conf /etc/

CMD supervisord -n -c /etc/supervisor.conf
