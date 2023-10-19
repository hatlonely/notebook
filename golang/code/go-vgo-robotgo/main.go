package main

import (
	"fmt"
	"github.com/go-vgo/robotgo"
	"os"
	"os/signal"
	"syscall"
)

func main() {
	// 设置信号处理函数，当收到中断信号时退出程序
	signalChan := make(chan os.Signal, 1)
	signal.Notify(signalChan, os.Interrupt, syscall.SIGTERM)
	go func() {
		<-signalChan
		os.Exit(0)
	}()

	// 监听键盘事件
	keve := robotgo.Start()
	for e := range keve {
		if e.Kind == 1 {
			fmt.Printf("Key down: %s\n", e.Key)
		} else if e.Kind == 2 {
			fmt.Printf("Key up: %s\n", e.Key)
		}
	}
}
