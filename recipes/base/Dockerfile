FROM golang

COPY go-wrapper /usr/local/bin/
RUN chmod +x /usr/local/bin/go-wrapper

RUN apt-get update \
    && DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
    python-pip \
    vim \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

RUN mkdir /root/.ssh/
ADD ./insecure_key /root/.ssh/
ADD ./insecure_key.pub /root/.ssh/
RUN chmod 0600 /root/.ssh/
RUN chown root /root/.ssh/

CMD bash
