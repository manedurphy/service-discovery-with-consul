#! /bin/bash

helm uninstall --namespace="consul" consul
kubectl delete ns consul
