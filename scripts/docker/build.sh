#! /bin/bash

docker build -f services/one/k8s/Dockerfile -t manedurphy/service-one .
docker build -f services/two/k8s/Dockerfile -t manedurphy/service-two .
