package main

import (
	"context"
	"math/rand"
	"time"

	"github.com/aws/aws-lambda-go/lambda"
)

func getRandomQuote() (string, error) {
	r := rand.New(rand.NewSource(time.Now().UnixNano()))
	quotes := []string{
		"Take up an idea, devote yourself, struggle in patience, and the sun will rise.",
		"Arise, awake, and don't stop till you reach your goal.",
		"The moral, in one word, is that you are divine.",
		"In a day, when you don't come across any problems - you can be sure that you are traveling the wrong path",
		"We are what our thoughts have made us; so take care about what you think. Words are secondary. Thoughts live; they travel far.",
		"Dare to be free, dare to go as far as your thought leads and dare to carry that out in your life.",
		"The great secret of true success, of true happiness is this: the man or woman who asks for no return, the perfectly unselfish person is the most successful.",
		"All powers in the universe are already ours. It is we who have put our hands before our eyes and cry that it is dark.",
		"If anything turns you weak physically, intellectually, and spiritually, reject it like it's poison.",
		"Talk to yourself once a day, otherwise, you may miss meeting an excellent person in this world."}
	idx := r.Intn(len(quotes))
	return quotes[idx], nil
}

func HandleRequest(ctx context.Context) (string, error) {
	return getRandomQuote()
}

func main() {
	lambda.Start(HandleRequest)
}
