package internal

import (
	"fmt"
	"bufio"
	"os"
	"strings"
)

type Cpu struct{
	Model string
	Cores int
	Threads int
}

func ShowCpu(){
	f, _ := os.Open("/proc/cpuinfo")
	defer f.Close()
	
	s := bufio.NewScanner(f)
	for s.Scan() {
		l := s.Text()
		if strings.Contains(l, "model name"){
			fmt.Println(l)
			break
		}
	}
	for s.Scan() {
		l := s.Text()
		if strings.Contains(l, "cpu cores"){
			fmt.Println(l)
			break
		}
	}
	for s.Scan() {
		l := s.Text()
		if strings.Contains(l, "siblings"){
			word := strings.Split(l, " ")
			fmt.Println(word[3])
			fmt.Println(l)
			break
		}
	}
}