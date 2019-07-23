// +build ignore
package main

import (
	"fmt"
	"hello/pb3"
	"log"
	"net/http"
	"net/url"
	"sync"

	"github.com/gorilla/websocket"
)

var addr = "localhost:8080"

func connect() (*websocket.Conn, *http.Response, error) {
	log.SetFlags(0)
	u := url.URL{Scheme: "ws", Host: addr, Path: "/"}
	log.Printf("connecting to %s", u.String())
	connection, response, err := websocket.DefaultDialer.Dial(u.String(), nil)
	if err != nil {
		log.Println("dial:", err)
	}
	return connection, response, err

}

func checkError(err error) {
	if err != nil {
		log.Println("Err:", err)
	}
}

func good(wg sync.WaitGroup) {

	connection, _, _ := connect()

	mes := new(pb3.Bail)
	mes.New()
	str, err := mes.ToByte()
	checkError(err)
	err5 := connection.WriteMessage(websocket.BinaryMessage, []byte(str))
	checkError(err5)
	for {
		_, bytes, err := connection.ReadMessage()
		if err != nil {
			log.Println("SocketClose:", err)
			err2 := connection.WriteMessage(websocket.CloseMessage, websocket.FormatCloseMessage(websocket.CloseNormalClosure, ""))
			fmt.Print(err2)
			break
		}
		fmt.Println(string(bytes))

	}
	wg.Done()

}

func main() {
	var wg sync.WaitGroup
	for i := 0; i < 100000; i++ {
		wg.Add(1)
		go good(wg)
	}
	wg.Wait()
}
