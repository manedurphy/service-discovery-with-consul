#! /bin/bash

kubectl apply -f configs/k8s/consul/consul_namespace.yaml
helm install -f ./configs/k8s/consul/consul.yaml --namespace="consul" consul hashicorp/consul
