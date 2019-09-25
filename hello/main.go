package main

import (
	"fmt"
	"math/rand"
	"time"
)

func main() {
	for j := 0; j <= 10; j++ {
		fmt.Println(randStock())
	}
}

func randStock() int {
	rand.NewSource(time.Now().UnixNano())
	allStock := []int{1, 2, 3, 4}
	num := rand.Intn(100) % len(allStock)
	return allStock[num]
}
