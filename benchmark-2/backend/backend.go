package main

import (
	"encoding/json"
	"fmt"
	"net/http"
	"runtime"
	"time"
)

type date_api_response struct {
	Year  int `json:"year"`
	Month int `json:"month"`
	Day   int `json:"day"`
}

type name_api_response struct {
	Name string `json:"name"`
}

func repeatedSlice[T any](value T, n int) []T {
	arr := make([]T, n)
	for i := 0; i < n; i++ {
		arr[i] = value
	}
	return arr
}

func dateHandler(wr http.ResponseWriter, req *http.Request) {
	if req.Method != "GET" {
		wr.WriteHeader(http.StatusMethodNotAllowed)
		return
	}

	year, month, day := time.Now().Date()
	cur_date := date_api_response{
		Year:  year,
		Month: int(month),
		Day:   day,
	}

	// Можно кешировать на прокси, в течение одного дня
	//   дата точно не поменяется!
	// Очень хорошо про cache-control.
	//   https://stackoverflow.com/a/70970543
	time_generated_str := time.Date(year, month, day, 00, 00, 00, 00, time.Now().Location()).UTC().Format(http.TimeFormat)
	wr.Header().Set("Last-Modified", time_generated_str)
	wr.Header().Set("Date", time_generated_str)
	wr.Header().Set("Cache-Control", fmt.Sprintf("public, max-age=%d", 24*60*60))

	dates := repeatedSlice(cur_date, 10_000)
	json.NewEncoder(wr).Encode(dates)
}

func nameHandler(wr http.ResponseWriter, req *http.Request) {
	if req.Method != "GET" {
		wr.WriteHeader(http.StatusMethodNotAllowed)
		return
	}

	var name_struct name_api_response
	err := json.NewDecoder(req.Body).Decode(&name_struct)
	if err != nil {
		wr.WriteHeader(http.StatusBadRequest)
		wr.Write([]byte("400 - Bad Request (invalid POST parameters)"))
		return
	}

	names := repeatedSlice(name_struct, 10_000)
	json.NewEncoder(wr).Encode(names)
}

func main() {
	// The reason I'm locking goroutines to a single thread
	//   (like limiting their threadpool to a single OS thread)
	//   is because I won't be able to see improvements with
	//   nginx balancing otherwise. Golang will utilize all
	//   cores for request processing. I will have to nginx proxy
	//   between machines to really see benefits of balancing.
	//   So let's make each backend instance seem like a
	//   low-performance machine.
	// Outcome: didn't make difference.
	// runtime.LockOSThread()
	// https://www.reddit.com/r/golang/comments/bj2zq5/comment/em4xgzl
	// Also, I am able to see difference with caching. So that's
	//   great I'll also make another backend, which will be slower.
	// To see the difference I may need to have more resource-heavy
	//   operations in handlers. Then I'll see balancing improving
	//   things.

	// Скажем, не все ресурсы доступны, а живем на отдельной машине с 3 ядрами.
	//   Тогда балансировка позволит включить в работу 6 ядер! А не три.
	runtime.GOMAXPROCS(1)

	http.HandleFunc("/what-date-is-it", dateHandler)
	http.HandleFunc("/what-is-my-name", nameHandler)

	http.ListenAndServe("0.0.0.0:80", nil)
}
