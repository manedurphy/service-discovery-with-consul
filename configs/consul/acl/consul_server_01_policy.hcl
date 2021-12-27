node "consul-server-1" {
	policy = "write"
}
service_prefix "" {
	policy = "read"
}
