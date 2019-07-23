// +build ignore
package main

import (
	"hello/dispatcher"
	"hello/pb3"
	"log"
	"net/http"

	"github.com/gorilla/websocket"
)

var address = "localhost:8080"
var upgrader = websocket.Upgrader{
	CheckOrigin: func(r *http.Request) bool {
		return true
	},
}

func checkError(err error) {
	if err != nil {
		log.Println("Err:", err)
	}
}

func upgradeToWebSocket(writer http.ResponseWriter, request *http.Request) (*websocket.Conn, error) {
	connection, err := upgrader.Upgrade(writer, request, nil)
	return connection, err
}

func home(writer http.ResponseWriter, request *http.Request) {
	connection, err := upgradeToWebSocket(writer, request)
	defer connection.Close()
	checkError(err)
	for {
		_, bytes, err2 := connection.ReadMessage()
		if err2 != nil {
			log.Println("SocketClose:", err2)
			break
		}
		code, _, _, err3 := pb3.SplitByte(bytes)
		if err3 != nil {
			log.Println("SplitByte:", err3)
			break
		}
		err4 := dispatcher.Dispatch(code, bytes, connection)
		if err4 != nil {
			log.Println("Dispatch:", err4)
			break
		}
	}
}

func main() {

	http.HandleFunc("/", home)
	log.Fatal(http.ListenAndServe(address, nil))
}
