#! /bin/bash

# Create agent token for consul-server-1
consul acl token create -description "consul-server-1 agent token" -policy-name "consul-server-1"

# Create agent token for consul-server-2
consul acl token create -description "consul-server-2 agent token" -policy-name "consul-server-2"

# Create agent token for consul-client-1
consul acl token create -description "consul-client-1 agent token" -policy-name "consul-client-1"

# Create agent token for consul-client-2
consul acl token create -description "consul-client-2 agent token" -policy-name "consul-client-2"
