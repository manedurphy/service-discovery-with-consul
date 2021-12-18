#! /bin/bash

helm upgrade -f ./configs/yaml/consul.yaml --namespace="consul" consul hashicorp/consul
