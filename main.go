package main

import (
	"fmt"
	"io/ioutil"
	"log"
	"net/http"
	"net/url"
)

const (
	httpHost = "0.0.0.0"
	localFile = "./saml-response.txt"
)

var (
	revision = "UNKNOWN"
	httpPort = "35001"
)

func main() {
	httpEndpoint := fmt.Sprintf("%v:%v", httpHost, httpPort)

	http.HandleFunc("/", SAMLServer)
	log.Printf("Version: %s\n", revision)
	log.Printf("Starting HTTP server at %s\n", httpEndpoint)

	err := http.ListenAndServe(httpEndpoint, nil)
	if (err != nil) {
		log.Printf("Error: %v\n", err.Error())
	}
}

func SAMLServer(w http.ResponseWriter, r *http.Request) {
	switch r.Method {
	case "POST":
		if err := r.ParseForm(); err != nil {
			fmt.Fprintf(w, "ParseForm() err: %v\n", err)
			log.Printf("ParseForm() err: %v\n", err)
			return
		}

		SAMLResponse := r.FormValue("SAMLResponse")
		if len(SAMLResponse) == 0 {
			fmt.Fprintf(w, "SAMLResponse field is empty or not exists\n")
			log.Printf("SAMLResponse field is empty or not exists\n")
			return
		}

		err := ioutil.WriteFile(localFile, []byte(url.QueryEscape(SAMLResponse)), 0600)
		if (err != nil) {
			fmt.Fprintf(w, "Got SAMLResponse field, but was not able to save it to file\n")
			log.Printf("Got SAMLResponse field, but was not able to save it to file: %s\n", localFile)
			return
		}

		fmt.Fprintf(w, "Got SAMLResponse field, it is now safe to close this window\n")
		log.Printf("Got SAMLResponse field, it is saved to file: %s\n", localFile)
		return
	default:
		fmt.Fprintf(w, "Error: POST method expected, %s recieved\n", r.Method)
		log.Printf("Error: POST method expected, %s recieved\n", r.Method)
	}
}
