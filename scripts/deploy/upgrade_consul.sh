#! /bin/bash

helm upgrade --values ./configs/k8s/consul/consul.yaml --namespace="consul" consul hashicorp/consul
