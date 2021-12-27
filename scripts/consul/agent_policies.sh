# Agent policy for consul-server-1
consul acl policy create -name consul-server-1 \
	-description "Agent policy for consul-server-1" \
	-datacenter "us-west-1" \
	-rules @configs/consul/acl/consul_server_01_policy.hcl

# Agent policy for consul-server-2
consul acl policy create -name consul-server-2 \
	-description "Agent policy for consul-server-2" \
	-datacenter "us-west-1" \
	-rules @configs/consul/acl/consul_server_02_policy.hcl

# Agent policy for consul-client-1
consul acl policy create -name consul-client-1 \
	-description "Agent policy for consul-client-1" \
	-datacenter "us-west-1" \
	-rules @configs/consul/acl/consul_client_01_policy.hcl

# Agent policy for consul-client-2
consul acl policy create -name consul-client-2 \
	-description "Agent policy for consul-client-2" \
	-datacenter "us-west-1" \
	-rules @configs/consul/acl/consul_client_02_policy.hcl
