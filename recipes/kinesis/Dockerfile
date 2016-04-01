FROM docker.local/aws

RUN mkdir -p /go/src/aws-kinesis
ADD ./src /go/src/aws-kinesis

WORKDIR /go/src/aws-kinesis
RUN go-wrapper download
RUN go-wrapper install

ENTRYPOINT ["aws-kinesis"]
