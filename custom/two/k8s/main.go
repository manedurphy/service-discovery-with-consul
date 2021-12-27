package main

import (
	"fmt"
	"net/http"
)

func main() {
	var (
		mux    *http.ServeMux
		server *http.Server
		err    error
	)

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

	fmt.Println("starting server on port 8081")
	if err = server.ListenAndServe(); err != nil {
		panic(err)
	}
}
