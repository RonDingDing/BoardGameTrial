package main

import (
	"fmt"
	"hello/baseroom"
	"hello/manila"
)

func main() {
	card := manila.ManilaStock{}.New(1)
	fmt.Println(card)
	var room baseroom.Room
	fmt.Println(room.GetStarted)
}
