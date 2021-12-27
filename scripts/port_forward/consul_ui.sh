#! /bin/bash

kubectl port-forward -n consul consul-server-0 8501:8501
