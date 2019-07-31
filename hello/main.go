package main

import (
	"fmt"
)

func task() {
	fmt.Println("I am runnning task.")
}
func main() {

	// gocron.Every(1).Second().Do(task)
	// gocron.Every(2).Seconds().Do(task)
	// gocron.Every(1).Minute().Do(task)
	// gocron.Every(2).Minutes().Do(task)
	// gocron.Every(1).Hour().Do(task)
	// gocron.Every(2).Hours().Do(task)
	// gocron.Every(1).Day().Do(task)
	// gocron.Every(2).Days().Do(task)
	// message := new(pb3.Bail)
	// message.New()
	// message.Req.Username = "apple"
	// message.Req.Able = []int32{2, 2}
	// message.Ans.Password = "apple"
	// fmt.Println(message)

	// ans := new(pb3.Bail_ANS)
	// ans.Password = "3"
	// message.SetAns(ans)
	// message.SetReq(req)
	// message.SetError(-22)
	// fmt.Println(message)
	// fmt.Println(message.ToByte())

	// message := new(pb3.Bail)
	// message.New()
	// req := new(pb3.Bail_REQ)
	// req.Password = "apple"
	// req.Username = "boy"
	// message.SetReq(req)
	// b, _ := message.ToByte()
	// fmt.Println(b)
	// message.FromByte(b)
	// fmt.Println(message)

}
