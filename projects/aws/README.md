# aws

## examples

### cli

```Shell
docker-compose build base
docker-compose run config
docker-compose run cli kinesis list-streams
docker-compose run cli kinesis put-records --generate-cli-skeleton
```

### kinesis list

```Shell
docker-compose build base
docker-compose run config
docker-compose run kinesis list
```

### kinesis put with one random message every 1 seconds

```Shell
docker-compose run kinesis feed {stream-name} 1 1000 
```

### kinesis batch put with custom data template

```Shell
docker-compose run kinesis feed {stream-name} 15 1000 /tmp/data.tmpl
```
