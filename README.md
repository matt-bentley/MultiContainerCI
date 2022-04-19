# MultiContainerCI


n.b. remember that docker-compose files must have unix line endings. Use VS Code or dos2unix.


## Build

```
docker-compose --profile ci build
```

## Run

```
docker-compose --profile test up

# stop and keep volume
docker-compose --profile test down

# stop and delete volume
docker-compose --profile test down -v
```

## Extract

```
./pipelines/scripts/docker-compose-extract.sh -p ci
```

## Promote

```
./pipelines/scripts/docker-compose-promote.sh -p ci -t 1.0.0 -r devregistry.io -u qaregistry.io
```

## Scan

```
./pipelines/scripts/docker-compose-command.sh -r devregistry.io/ -p ci -t 1.0.0 -c "dive @image"
```