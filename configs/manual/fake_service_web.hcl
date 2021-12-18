service {
	name = "web"
	port = 8080
	tags = ["fake-service-web"]

	checks = [
    {
      id = "web_check"
      name = "Check WEB health 8080"
      service_id = "web"
      http = "http://localhost:8080/health"
      method = "GET"
      interval = "10s"
      timeout = "1s"
      success_before_passing = 3
      failures_before_critical = 3
    }
  ]
}