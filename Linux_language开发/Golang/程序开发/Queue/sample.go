package main

import (
	"fmt"
	"strconv"
	"container/list"
)

func main() {

	// 初始化
	queue := list.New()

	// 入队
	queue.PushBack("1")
	queue.PushBack("2")
	queue.PushBack("3")
	queue.PushBack("4")
	queue.PushBack("5")

	fmt.Println("queue len", queue.Len())

	fmt.Println("Remove queue.Front()", queue.Remove(queue.Front()))
	fmt.Println("Remove queue.Front().Next()", queue.Remove(queue.Front().Next()))

	for e := queue.Front(); e != nil; e = e.Next() {
		// fmt.Println(e.Value)
		value, _ := strconv.Atoi(e.Value.(string))
		fmt.Println(value)
	}
}


