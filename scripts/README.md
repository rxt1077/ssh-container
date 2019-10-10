# Scripts

This directory contains various scripts used in this project

## container_environment.sh

Starts a new container and drops the student into a shell within that
container. Deletes the container on exit.

## build_image.sh

Creates the LXC image used by `container_environment.sh` to create containers
when a student signs in.

## delete_all_ssh-containers.sh

Deletes all containers with the `ssh-container` prefix
