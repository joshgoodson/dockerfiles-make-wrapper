FROM aws_base:latest

RUN mkdir -p /go/src/go-feeder/
ADD ./src/go-feeder/ /go/src/go-feeder/
WORKDIR /go/src/go-feeder/
RUN go-wrapper download

ENTRYPOINT ["/bin/bash"]
