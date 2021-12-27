node "consul-server-2" {
	policy = "write"
}
service_prefix "" {
	policy = "read"
}