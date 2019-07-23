package main

import (
	"fmt"

	"github.com/jasonlvhit/gocron"
)

func task() {
	fmt.Println("I am runnning task.")
}
func main() {

	gocron.Every(1).Second().Do(task)
	gocron.Every(2).Seconds().Do(task)
	gocron.Every(1).Minute().Do(task)
	gocron.Every(2).Minutes().Do(task)
	gocron.Every(1).Hour().Do(task)
	gocron.Every(2).Hours().Do(task)
	gocron.Every(1).Day().Do(task)
	gocron.Every(2).Days().Do(task)
	// message := new(pb3.Bail)
	// message.New()

	// // req := new(pb3.Bail_REQ)
	// // req.Username = "apple"
	// // ans := new(pb3.Bail_ANS)
	// // ans.Password = "3"
	// // message.SetAns(ans)
	// // message.SetReq(req)
	// // message.SetError(-22)
	// fmt.Println(message)
	// fmt.Println(message.ToByte())

	// message := new(pb3.Mail)
	// message.New()
	// b, _ := message.ToByte()
	// message.FromByte(b)
	// fmt.Println(message)
	// // bytes := []byte{8, 177, 9, 18, 2, 123, 125, 26, 7, 10, 5, 97, 112, 112, 108, 101, 34, 3, 18, 1, 51, 40, 234, 255, 255, 255, 255, 255, 255, 255, 255, 1}
	// // message.FromByte(bytes)
	// // fmt.Println(message)

}
