# The region of the Consul cluster
datacenter = "us-west-1"

# The data directory stores the Consul data
data_dir = "/opt/consul"

# The UI configuration
ui_config {
	enabled = true
}

# Configures the ports
ports {
	http = 3000
}

# The address to which Consul will bind client interfaces
client_addr = "0.0.0.0"

# Sets the instance to run in server mode
server = true

# Address for internal communication within the Consul cluster
bind_addr = "0.0.0.0"

# The address to advertise to other nodes in the Consul cluster
advertise_addr = "{{ GetInterfaceIP `ens5` }}"

# The number of expected servers
bootstrap_expect = 3

# The address of the node to join on start up
retry_join = ["172.31.107.196", "172.31.105.153", "172.31.110.188"]
