// +build ignore
package main

import (
	"flag"
	"hello/dispatcher"
	"log"
	"net/http"

	"github.com/astaxie/beego/orm"
	"github.com/gorilla/websocket"
)

var addr = flag.String("addr", "localhost:8080", "http service address")

var upgrader = websocket.Upgrader{
	CheckOrigin: func(request *http.Request) bool {
		return true
	},
}

func server(writer http.ResponseWriter, request *http.Request) {
	connection, err := upgrader.Upgrade(writer, request, nil)

	if err != nil {
		log.Print("upgrade:", err)
		return
	}
	ormManager := orm.NewOrm()
	ormManager.Using("default")

	defer connection.Close()
	for {
		messageType, message, err := connection.ReadMessage()
		if err != nil {
			log.Printf("%-8s: %s\n", "readerr", err)
			break
		}
		dispatcher.Dispatch(messageType, message, connection, ormManager)

	}
}

func main() {

	flag.Parse()
	log.SetFlags(0)
	http.HandleFunc("/", server)
	log.Fatal(http.ListenAndServe(*addr, nil))
}
