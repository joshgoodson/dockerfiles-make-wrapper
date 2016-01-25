FROM python:2.7.10-wheezy

RUN apt-get update \
    && DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
        groff \
        less \
        g++ \
        gcc \
        libc6-dev \
        make \
        && apt-get clean \
        && rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

# install aws cli and python sdk
RUN pip install --upgrade pip
RUN pip install awscli
RUN pip install boto

# download ecs-cli
RUN curl -fsSL \
    https://s3.amazonaws.com/amazon-ecs-cli/ecs-cli-linux-amd64-latest \
    -o /usr/local/bin/ecs-cli \
    && chmod +x /usr/local/bin/ecs-cli

# setup go
ENV GOLANG_VERSION 1.5.1
ENV GOLANG_DOWNLOAD_URL https://golang.org/dl/go$GOLANG_VERSION.linux-amd64.tar.gz
ENV GOLANG_DOWNLOAD_SHA1 46eecd290d8803887dec718c691cc243f2175fe0
RUN curl -fsSL "$GOLANG_DOWNLOAD_URL" -o golang.tar.gz \
    && echo "$GOLANG_DOWNLOAD_SHA1  golang.tar.gz" | sha1sum -c - \
    && tar -C /usr/local -xzf golang.tar.gz \
    && rm golang.tar.gz
ENV GOPATH /go
ENV PATH $GOPATH/bin:/usr/local/go/bin:$PATH
RUN mkdir -p "$GOPATH/src" "$GOPATH/bin" && chmod -R 777 "$GOPATH"
COPY go-wrapper /usr/local/bin/
RUN chmod +x /usr/local/bin/go-wrapper

# install go sdk
RUN go get -u github.com/aws/aws-sdk-go/...
RUN mkdir -p /root/.aws/
RUN touch /root/.aws/config
RUN touch /root/.aws/credentials

# term defaults
ENV TERM xterm
COPY bashrc /root/.bashrc
WORKDIR /root/
ENTRYPOINT ["aws"]
CMD ["--version"]
