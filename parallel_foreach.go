package main

import (
	"flag"
	"fmt"
	"io/ioutil"
	"log"
	"os/exec"
	"sync"
)

func main() {
	input_directory_flag := flag.String("inputdir", "./", "Input directory")
	workers_flag := flag.Int("workers", 6, "Maximum amount of concurrent goroutines")
	flag.Parse()
	workers := *workers_flag
	input_directory := *input_directory_flag

	ch := make(chan string)
	wg := sync.WaitGroup{}
	for i := 0; i < workers; i++ {
		wg.Add(1)
		go worker(ch, &wg)
	}

	files, err := ioutil.ReadDir(input_directory)
	if err != nil {
		log.Fatal(err)
	}

	for index, f := range files {
		fmt.Printf("progress: %d/%d\n", index+1, len(files))
		ch <- "echo " + f.Name() // just a simple example
	}

	close(ch)
	wg.Wait()
}
func worker(ch chan string, wg *sync.WaitGroup) {
	for command := range ch {
		cmd := exec.Command("/bin/bash", "-c", command)
		output, err := cmd.CombinedOutput()
		if err != nil {
			fmt.Println(fmt.Sprint(err) + ": " + string(output))
		}
		fmt.Println(string(output))
	}
	wg.Done()
}
