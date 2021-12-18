#! /bin/bash

kubectl exec --namespace consul consul-server-0 -- consul members
