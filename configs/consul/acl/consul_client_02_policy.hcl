node "consul-client-2" {
	policy = "write"
}
service_prefix "" {
	policy = "read"
}
