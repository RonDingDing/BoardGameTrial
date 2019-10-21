package main

import (
	"fmt"
	"hello/manila"
	"math/rand"
	"time"
)

func main() {
	deck := make([]manila.ManilaStock, 0)

	for j := 1; j < 5; j++ {
		for i := 0; i < 5; i++ {
			card := new(manila.ManilaStock).New(j)
			deck = append(deck, *card)
		}
	}
	rand.Seed(time.Now().UnixNano())
	for i := 0; i < len(deck); i++ {
		swap := rand.Intn(100) % len(deck)

		deck[i], deck[swap] = deck[swap], deck[i]

	}
	fmt.Println(deck)

}
