#! /bin/bash

helm install --values ./configs/k8s/consul/consul.yaml --create-namespace --namespace="consul" consul hashicorp/consul
