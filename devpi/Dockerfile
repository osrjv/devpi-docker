FROM python:3.7
MAINTAINER Ossi Rajuvaara <ossi@robocorp.com>

VOLUME /data
EXPOSE 8000

RUN  \
    apt-get update && \
    apt-get -y upgrade && \
    apt-get -y install apache2-utils && \
    apt-get -y autoremove && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

COPY requirements.txt /
RUN pip install --no-cache-dir -U pip setuptools
RUN pip install --no-cache-dir -r /requirements.txt

COPY entrypoint.sh /
RUN chmod +x /entrypoint.sh

ENTRYPOINT [ "/entrypoint.sh" ]
