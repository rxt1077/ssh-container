#!/bin/bash

for NAME in $( lxc ls --columns=n --format csv | grep ssh-container); do
	lxc stop ${NAME}
	lxc delete ${NAME}
done
