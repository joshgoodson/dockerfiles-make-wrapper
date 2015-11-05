# aws

## examples

### cli

```Shell
docker-compose build base
docker-compose run config
docker-compose run cli kinesis list-streams
docker-compose run cli kinesis put-records --generate-cli-skeleton
```

### kinesis

```Shell
docker-compose build base
docker-compose run config
docker-compose run kinesis list
docker-compose run kinesis feed {stream-name} 15
```
