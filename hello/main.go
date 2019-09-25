package main

import "fmt"

func main() {
	a := A{b: B{c: C{d: "apple"}}}
	fmt.Println(a.b.c)
}

type A struct {
	b B
}

type B struct {
	c C
}
type C struct {
	d string
}
