package main

import "fmt"

func main() {
	a := []string{"s", "a", "d"}
	c := append(a, a...)
	dic := map[string]bool{"s": true, "a": false, "d": false}
	s := "s"

	m := get(s, c, dic)
	fmt.Print(m)
}

func get(username string, names []string, dic map[string]bool) string {
	for i := 0; i < len(names); i++ {
		if names[i] == username {
			for m := i + 1; m < len(names); m++ {
				checkName := names[m]
				if username != checkName && dic[checkName] == true {
					return checkName
				}
			}
			break
		}
	}
	return ""

}
