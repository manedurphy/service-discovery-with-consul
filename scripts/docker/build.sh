#! /bin/bash

docker build -f custom/one/k8s/Dockerfile -t manedurphy/one .
docker build -f custom/two/k8s/Dockerfile -t manedurphy/two .
