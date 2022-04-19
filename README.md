# MultiContainerCI

This is a reference project for working with multiple containers at the same time.

A **docker-compose** file is used to perform the following actions on multiple images at once:

- Build images
- Run images for testing purposes
- Execute a command on each image. This can be used for DevSecOps processes such as image scanning
- Promote images from one registry to another

The repository uses docker-compose **profiles** to control which images actions are performed on. Profiles can also be used to distrobute actions across parallel processes to improve build/scan times.

## Sample Project

The project consists of the following applications:

- .NET Blazor Webassembly web application
- .NET Worker agent console application
- SQL Server database

The application consists of a simple Web UI for retrieving random **weather forecasts** from a SQL Server database. The agent service updates the forecasts every *10 seconds* and performs the initial database schema migration when started.

## Build

The `ci` profile can be used to build all of the application code images:

```bash
docker-compose --profile ci build
```

## Run

The `test` profile can be used to run the applications. The SQL data will be stored in a persistent volume so that it is not deleted when the containers are stopped and started:

```bash
docker-compose --profile test up

# stop and keep volume
docker-compose --profile test down

# stop and delete volume
docker-compose --profile test down -v
```

## Extract

The following script can be used to extract the docker image names from a docker-compose file:

```bash
./pipelines/scripts/docker-compose-extract.sh -p ci

# ${DOCKER_REGISTRY}multicontainers/agent:${TAG:-dev}
# ${DOCKER_REGISTRY}multicontainers/web:${TAG:-dev}
```

Various options are provided for filtering which image names are extracted. The options can be viewed using the help option:

```bash
./pipelines/scripts/docker-compose-extract.sh -h

# Usage: ./docker-compose-extract.sh [OPTIONS]
# 
# Extract values from a Docker-Compose file
# 
# Options:
#   -f                   Path for docker-compose file.
#   -i                   Image filter - the image name must contain this string.
#   -e                   Image exclude filter - the image name must not contain this string.
#   -p                   Profile.
#   -h                   Print this Help.
```

n.b. docker-compose files must have unix line endings to work within the provided bash scripts. Use VS Code or dos2unix to convert from Windows to Unix line endings if required.

## Promote

The following script can be used to promote images from one registry to another using `docker tag`:

```bash
./pipelines/scripts/docker-compose-promote.sh -p ci -t 1.0.0 -r devregistry.io -u qaregistry.io

# Filtering images for profile: ci
# Promoting images from devregistry.io to qaregistry.io
# Tagging images from: docker-compose.yml
# docker tag devregistry.io/multicontainers/agent:1.0.0 qaregistry.io/multicontainers/agent:1.0.0
# docker tag devregistry.io/multicontainers/web:1.0.0 qaregistry.io/multicontainers/web:1.0.0
```

Various options are provided for filtering which image names are extracted. The options can be viewed using the help option:

```bash
./pipelines/scripts/docker-compose-promote.sh -h

# Usage: ./docker-compose-promote.sh [OPTIONS] -r REGISTRY -u PROMOTE_REGISTRY
# 
# Tag images from a Docker-Compose file for promoting to a new environment
# 
# Mandatory Options:
#   -r                   Docker registry to promote from.
#   -u                   Upper Docker registry to promote to.
# 
# Options:
#   -f                   Path for docker-compose file.
#   -p                   Profile filter.
#   -i                   Image filter - the image name must contain this string.
#   -e                   Image exclude filter - the image name must not contain this string.
#   -t                   Image tag - defaults to 'latest'.
#   -h                   Print this Help.
```

## Execute Command

The following script can be run to execute a command on each image. This is useful for **DevSecOps** activities such as container scanning.

The example below uses [Dive](https://github.com/wagoodman/dive) to analyse wasted space in the containers:

```bash
./pipelines/scripts/docker-compose-command.sh -r devregistry.io -p ci -t 1.0.0 -c "dive @image"

# Filtering images for profile: ci
# Running command against images from: docker-compose.yml
# dive devregistry.azurecr.io/multicontainers/agent:20220419.16
#   Using default CI config
# Image Source: docker://devregistry.azurecr.io/multicontainers/agent:20220419.16
# Fetching image... (this can take a while for large images)
# Analyzing image...
#   efficiency: 99.4432 %
#   wastedBytes: 2219266 bytes (2.2 MB)
#   userWastedPercent: 1.8069 %
# Inefficient Files:
# Count  Wasted Space  File Path
#     2        1.6 MB  /var/cache/debconf/templates.dat
#     2        226 kB  /lib/x86_64-linux-gnu/libz.so.1.2.11
#     2        169 kB  /var/lib/dpkg/status-old
#     2        169 kB  /var/lib/dpkg/status
#     2         21 kB  /var/cache/debconf/config.dat
#     2         13 kB  /etc/ld.so.cache
#     2         11 kB  /var/lib/apt/extended_states
#     2        9.4 kB  /var/log/apt/eipp.log.xz
#     2        6.1 kB  /var/lib/dpkg/info/zlib1g:amd64.symbols
#     2        5.8 kB  /usr/share/doc/zlib1g/copyright
#     2         556 B  /var/lib/dpkg/info/zlib1g:amd64.md5sums
#     2         522 B  /var/lib/dpkg/info/zlib1g:amd64.list
#     2         166 B  /var/lib/dpkg/info/zlib1g:amd64.shlibs
#     2         132 B  /var/lib/dpkg/info/zlib1g:amd64.triggers
#     2           0 B  /var/lib/dpkg/lock
#     2           0 B  /var/lib/dpkg/triggers/Lock
#     2           0 B  /var/lib/dpkg/triggers/Unincorp
#     2           0 B  /lib/x86_64-linux-gnu/libz.so.1
# Results:
#   PASS: highestUserWastedPercent
#   SKIP: highestWastedBytes: rule disabled
#   PASS: lowestEfficiency
# Result:PASS [Total:3] [Passed:2] [Failed:0] [Warn:0] [Skipped:1]
#
# ...
```

Various options are provided for filtering which image names are extracted. The options can be viewed using the help option:

```bash
./pipelines/scripts/docker-compose-command.sh -h

# Usage: ./docker-compose-command.sh [OPTIONS] -c 'dive @image'
# 
# Run a command against images from a Docker-Compose file.
# @image is replaced with the name of the docker image.
# 
# Mandatory Options:
#   -c                   Command to run against each image.
# 
# Options:
#   -f                   Path for docker-compose file.
#   -p                   Profile filter.
#   -i                   Image filter - the image name must contain this string.
#   -e                   Image exclude filter - the image name must not contain this string.
#   -t                   Image tag - defaults to 'latest'.
#   -h                   Print this Help.
```

## Pipelines

Examples are shown for executing these tasks in an automated Azure DevOps pipeline - please see `pipelines/azure-pipelines.yml`.