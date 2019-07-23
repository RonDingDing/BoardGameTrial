package main

import (
	"fmt"
)

func main() {

	const (
		mutexLocked = 1 << iota // mutex is locked
		mutexWoken
		mutexStarving
		mutexWaiterShift = iota
	)

	fmt.Println(mutexLocked)
	fmt.Println(mutexWoken)
	fmt.Println(mutexStarving)
	fmt.Println(mutexWaiterShift)
}
