# The region of the Consul cluster
datacenter = "us-west-1"

# The data directory stores the Consul data
data_dir = "/opt/consul"

# The address to which Consul will bind client interfaces
client_addr = "0.0.0.0"

# Sets the instance to run in server mode
server = false

# The address to advertise to other nodes in the Consul cluster
advertise_addr = "{{ GetInterfaceIP `ens5` }}"

# The address of the node to join on start up
retry_join = ["172.31.107.196", "172.31.105.153", "172.31.110.188"]
