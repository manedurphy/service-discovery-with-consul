#! /bin/bash

minikube start \
	--driver="docker" \
	--cpus="2" \
	--memory="4096" \
	--nodes="3"
