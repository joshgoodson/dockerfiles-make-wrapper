FROM docker.local/base

RUN apt-get update \
    && DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends \
    groff \
    less \
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

# install go sdk
RUN go get -u github.com/aws/aws-sdk-go/...
RUN mkdir -p /root/.aws/
RUN touch /root/.aws/config
RUN touch /root/.aws/credentials

VOLUME /root/.aws
ADD entrypoint.sh /entrypoint.sh
ENTRYPOINT ["/entrypoint.sh"]
CMD ["config"]
