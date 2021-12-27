#! /bin/bash

echo "Loading image to Minikube"
minikube image load manedurphy/service-one
minikube image load manedurphy/service-two
echo "Done!"