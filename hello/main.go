package main

import (
	"fmt"
	"math/rand"
	"time"
	"strconv"
)

func CastDice() []int {
	rand.Seed(time.Now().UnixNano())
	result := []int{0, 0, 0, 0}
	for k, v := range []int{1, 2, 3, -1} {
		if v != -1 {
			result[k] = rand.Intn(6) + 1
		}
	}

	return result
}

func main() {
	fmt.Println(strconv.Itoa(1))
}
