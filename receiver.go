package main

import (
	"context"
	"fmt"
	"sync"

	"cloud.google.com/go/pubsub"
)

func main() {
	fmt.Println("Start pulling messages!")
	pullMsgs("yluu-gke-dev", "windows_container_update")
}

// func pullMsgs(w io.Writer, projectID, subID string) error {
func pullMsgs(projectID, subID string) error {
	// projectID := "my-project-id"
	// subID := "my-sub"
	ctx := context.Background()
	client, err := pubsub.NewClient(ctx, projectID)
	if err != nil {
		return fmt.Errorf("pubsub.NewClient: %v", err)
	}

	// Consume 10 messages.
	var mu sync.Mutex
	received := 0
	sub := client.Subscription(subID)
	cctx, cancel := context.WithCancel(ctx)
	err = sub.Receive(cctx, func(ctx context.Context, msg *pubsub.Message) {
		mu.Lock()
		defer mu.Unlock()
		fmt.Printf("Got message: %q\n", string(msg.Data))
		// fmt.Fprintf(w, "Got message: %q\n", string(msg.Data))
		msg.Ack()
		received++
		if received == 1 {
			cancel()
		}
	})
	if err != nil {
		return fmt.Errorf("Receive: %v", err)
	}
	return nil
}
