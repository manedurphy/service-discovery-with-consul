#! /bin/bash

helm install --values ./configs/k8s/consul/insecure.yaml --create-namespace --namespace="consul" consul hashicorp/consul
