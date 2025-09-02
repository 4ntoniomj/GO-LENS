package internal

import (
	"fmt"
	"os"
	"log"
	"strings"
	"strconv"
)

type Mem struct {
	Mem int
	Memused int
	Mempor float64
}

func Mem_show() {
	data, err := os.ReadFile("/proc/meminfo")
    if err != nil {
        log.Fatal("Only for linux")
    }

    lines := strings.Split(string(data), "\n")
	var tems []int
    for i := 0; i < 2; i++ {
		mem := strings.Fields(lines[i])
		memmb, err := strconv.Atoi(mem[1])
		if err != nil{
			log.Fatal(err)
		}
		memmbb := memmb / 1024
		tems = append(tems, memmbb)
    }
	porce := (float64(tems[0]) - float64(tems[1])) / float64(tems[0]) * 100 
	Output := Mem{
		Mem: tems[0],
		Memused: tems[1],
		Mempor: porce,
	}
	fmt.Printf("Total Mem: %v MB\nFree Mem: %v MB\nPorcentage: %.2f%%\n", Output.Mem, Output.Memused, Output.Mempor)
}