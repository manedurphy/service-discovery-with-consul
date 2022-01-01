Kind = "service-splitter"
Name = "api"
Splits = [
  {
    Weight        = 75
    ServiceSubset = "v1"
    ResponseHeaders {
      Set {
        "x-api-version" = "v1"
      }
    }
  },
  {
    Weight        = 25
    ServiceSubset = "v2"
    ResponseHeaders {
      Set {
        "x-api-version" = "v2"
      }
    }
  },
]
