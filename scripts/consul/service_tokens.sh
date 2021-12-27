#! /bin/bash

# Create service token for api service
consul acl token create -description "Token for API" -service-identity "api"

# Create service token for web service
consul acl token create -description "Token for WEB" -service-identity "web"
