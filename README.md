# dockerfiles

## OSX Requirements
[Docker](https://beta.docker.com/docs/) >= 1.10.3, build 20f81dd

### make
![make](/../master/make.png?raw=true "make")

### sshd ~ sample sshd daemon in a container
```make up sshd```

### ssh ~ ssh client - depends on sshd service
```make run ssh```

### aws ~ aws cli config
```
make run aws config
AWS Access Key ID [****************722Q]:
AWS Secret Access Key [****************AB3m]:
Default region name [us-west-2]:
Default output format [table]:
```

### aws ~ aws cli help
```make run aws help```

### aws ~ aws - list kinesis streams
```make run aws kinesis list-streams```

### kinesis ~ put with one random message every 1 seconds
```make run kinesis feed [stream] 1 1000```

### eclipse che ~ local eclipse che server
```
make up che
make open
```

#### CREDITS
[docker-ssh-agent-forward](https://github.com/avsm/docker-ssh-agent-forward)
