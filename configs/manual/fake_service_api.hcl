service {
  name = "api"
  port = 8080
  tags = ["fake-service-api"]
  
  checks = [
    {
      id = "api_check"
      name = "Check API health 8080"
      service_id = "api"
      http = "http://localhost:8080/health"
      method = "GET"
      interval = "10s"
      timeout = "1s"
      success_before_passing = 3
      failures_before_critical = 3
    }
  ]
}
