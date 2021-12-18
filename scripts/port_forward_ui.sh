#! /bin/bash

kubectl port-forward -n consul consul-server-0 8500:8500
