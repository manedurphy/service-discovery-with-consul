#! /bin/bash

echo "Loading image to Minikube"
minikube image load manedurphy/one
minikube image load manedurphy/two
echo "Done!"