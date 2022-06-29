FROM ubuntu:latest

# setup zoneinfo
RUN ln -snf /usr/share/zoneinfo/$INPUT_ZONEINFO /etc/localtime && echo $INPUT_ZONEINFO > /etc/timezone

RUN apt update
RUN apt install -y build-essential gcc-multilib g++-multilib cmake python3-setuptools python3-dev libffi-dev z3 clang valgrind libcurl4-gnutls-dev libxml2-dev libssl-dev wget
RUN apt install -y r-base

# Copy the files to the root filesystem of the container
COPY src/entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

# Executes `entrypoint.sh` when the Docker container starts up
ENTRYPOINT ["/entrypoint.sh"]