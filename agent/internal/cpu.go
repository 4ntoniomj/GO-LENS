package internal

import (
	"bufio"
	"fmt"
	"log"
	"os"
	"strconv"
	"strings"
	"time"
)

// struct for output
type Cpu struct{
	Model string
	Cores int
	Threads int
	Por float64
}

func ShowCpu(){
	var Output Cpu
	//open file
	f, _ := os.Open("/proc/cpuinfo")
	defer f.Close()
	
	// scan file and filter the file by words
	s := bufio.NewScanner(f)
	for s.Scan() {
		l := s.Text()
		if strings.Contains(l, "model name"){
			name := strings.Split(l, ": ")
			Output.Model = name[1]
			break
		}
	}
	// scan file and filter the file by words
	for s.Scan() {
		l := s.Text()
		if strings.Contains(l, "cpu cores"){
			name := strings.Split(l, " ")
			cores, _ := strconv.Atoi(name[2])
			Output.Cores = cores
			break
		}
	}
	// scan file and filter the file by words
	for s.Scan() {
		l := s.Text()
		if strings.Contains(l, "siblings"){
			word := strings.Split(l, " ")
			sblings, _ := strconv.Atoi(word[1])
			Output.Threads = sblings
			break
		}
	}
	// Open file
	f, _ = os.Open("/proc/stat")
	defer f.Close()

	// new and take the first line
	s = bufio.NewScanner(f)
	s.Scan()
	l := s.Text()
	// separated by spaces
	idle := strings.Split(l, " ")

	// first data for calc %
	var res float64
	for a, i := range idle {
		if a == 0 {
			continue
		}
		if i == "" {
			continue
		}
		// convert to int
		n, err := strconv.Atoi(i)
		if err != nil {
			log.Fatal(err)
		}
		num := float64(n)
		res = res + num
	}

	i1e, err := strconv.Atoi(string(idle[5]))
	if err != nil {
		log.Fatal(err)
	}
	i1 := float64(i1e)

	time.Sleep(1 * time.Second)
	// other time open file
	f, _ = os.Open("/proc/stat")
	defer f.Close()

	// new scan and take the first line
	s = bufio.NewScanner(f)
	s.Scan()
	l = s.Text()

	idle2 := strings.Split(l, " ")

	var res2 float64
	for a, i := range idle2 {
		if a == 0 {
			continue
		}
		if i == "" {
			continue
		}
		n, err := strconv.Atoi(i)
		if err != nil {
			log.Fatal(err)
		}
		num := float64(n)
		res2 = res2 + num
	}
	i2e, err := strconv.Atoi(idle2[5])
	if err != nil {
		log.Fatal(err)
	}
	i2 := float64(i2e)

	// Calc % and print
	calcl := 100 * (1 - ((i2 - i1) / (res2 - res)))
	Output.Por = calcl
	fmt.Printf("Model: %v\nCores: %v\nThreads: %v\nPorcentage: %.2f%%", Output.Model, Output.Cores, Output.Threads, Output.Por)
}