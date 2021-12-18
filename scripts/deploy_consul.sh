#! /bin/bash

kubectl apply -f configs/yaml/consul_namespace.yaml
helm install -f ./configs/yaml/consul.yaml --namespace="consul" consul hashicorp/consul
