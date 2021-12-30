#! /bin/bash

minikube start \
	--driver="docker" \
	--nodes="3" \
	--cpus="2" \
	--memory="2048" \
	--disk-size="20000mb" \
	--container-runtime="containerd"