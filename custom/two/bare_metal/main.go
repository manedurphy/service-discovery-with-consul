package main

import (
	"fmt"
	"net/http"
	"os"
	"os/signal"
	"syscall"

	"github.com/hashicorp/consul/api"
)

type Service struct {
	Name         string
	ConsulClient *api.Client
}

func NewService(name string) (*Service, error) {
	var (
		client     *api.Client
		serviceDef *api.AgentServiceRegistration
		s          *Service
		err        error
	)

	if client, err = api.NewClient(api.DefaultConfig()); err != nil {
		return nil, err
	}

	s = &Service{
		Name:         name,
		ConsulClient: client,
	}

	serviceDef = &api.AgentServiceRegistration{
		Name: name,
		Meta: map[string]string{
			"location": "atlanta",
			"region":   "us-east-1",
		},
		Port: 8081,
		Connect: &api.AgentServiceConnect{
			SidecarService: &api.AgentServiceRegistration{},
		},
		Check: &api.AgentServiceCheck{
			Name:                           "Service Two health check",
			HTTP:                           "http://localhost:8081/healthz",
			Method:                         http.MethodGet,
			Notes:                          "Health check endpoint for service two",
			DeregisterCriticalServiceAfter: "1m",
			Timeout:                        "5s",
			Interval:                       "10s",
			TLSSkipVerify:                  true,
		},
	}

	if err := s.ConsulClient.Agent().ServiceRegister(serviceDef); err != nil {
		return nil, err
	}

	return s, nil
}

func main() {
	var (
		svc    *Service
		mux    *http.ServeMux
		server *http.Server
		sigs   chan os.Signal
		err    error
	)
	if svc, err = NewService("service_two"); err != nil {
		panic(err)
	}

	mux = http.NewServeMux()
	mux.HandleFunc("/healthz", func(w http.ResponseWriter, r *http.Request) {
		w.WriteHeader(http.StatusOK)
		w.Write([]byte("healthy"))
	})

	mux.HandleFunc("/hello", func(w http.ResponseWriter, r *http.Request) {
		w.WriteHeader(http.StatusOK)
		w.Write([]byte("hello from service two"))
	})

	server = &http.Server{
		Addr:    ":8081",
		Handler: mux,
	}

	sigs = make(chan os.Signal, 1)
	signal.Notify(sigs, syscall.SIGINT, syscall.SIGTERM)
	go func() {
		<-sigs
		fmt.Println("exiting program")
		if err := svc.ConsulClient.Agent().ServiceDeregister(svc.Name); err != nil {
			panic(err)
		}
		os.Exit(0)
	}()

	fmt.Println("starting server on port 8081")
	if err = server.ListenAndServe(); err != nil {
		panic(err)
	}
}
