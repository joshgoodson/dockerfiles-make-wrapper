FROM aws_base:latest

RUN mkdir -p /go/src/aws-kinesis/
ADD ./src/aws-kinesis/ /go/src/aws-kinesis/
WORKDIR /go/src/aws-kinesis/
RUN go-wrapper download

ENTRYPOINT ["/bin/bash"]
