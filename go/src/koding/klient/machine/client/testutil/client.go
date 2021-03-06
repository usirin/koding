package testutil

import (
	"context"
	"fmt"
	"sync"
	"sync/atomic"
	"time"

	"koding/klient/machine"
	"koding/klient/machine/client"
)

// Builder uses Server logic to build test clients.
type Builder struct {
	c       *Client
	buildsN int64
	ch      chan struct{}
}

// NewBuilder creates a new Builder object that uses provided test client. If
// test client is nil, the default one will be created.
func NewBuilder(c *Client) *Builder {
	if c == nil {
		c = NewClient()
	}

	return &Builder{
		c:  c,
		ch: make(chan struct{}),
	}
}

// Ping returns machine statuses based on Server response.
func (*Builder) Ping(dynAddr client.DynamicAddrFunc) (machine.Status, machine.Addr, error) {
	if dynAddr == nil {
		panic("nil dynamic function generator")
	}

	states := map[string]machine.State{
		"":    machine.StateUnknown,
		"on":  machine.StateOnline,
		"off": machine.StateOffline,
	}
	for network, state := range states {
		if addr, err := dynAddr(network); err == nil {
			return machine.Status{State: state}, addr, err
		}
	}

	return machine.Status{}, machine.Addr{}, machine.ErrAddrNotFound
}

// Build creates a nil client and increases builds counter.
func (n *Builder) Build(ctx context.Context, _ machine.Addr) client.Client {
	go func() {
		atomic.AddInt64(&n.buildsN, 1)
		n.ch <- struct{}{}
	}()

	n.c.SetContext(ctx)
	return n.c
}

// WaitForBuild waits for invocation of Build method. It times out after
// specified duration.
func (n *Builder) WaitForBuild(timeout time.Duration) error {
	select {
	case <-n.ch:
		return nil
	case <-time.After(timeout):
		return fmt.Errorf("timed out after %s", timeout)
	}
}

// BuildsCount returns how many times Build method was invoked.
func (n *Builder) BuildsCount() int {
	return int(atomic.LoadInt64(&n.buildsN))
}

// Client satisfies machine.Client interface. It mimics real client and should
// be used for testing purposes.
type Client struct {
	client.Disconnected

	mu  sync.Mutex
	ctx context.Context
}

// NewClient create a new Client instance with background context.
func NewClient() *Client {
	return &Client{
		ctx: context.Background(),
	}
}

// SetContext sets provided context to test client.
func (c *Client) SetContext(ctx context.Context) {
	c.mu.Lock()
	defer c.mu.Unlock()

	c.ctx = ctx
}

// Context returns test client context.
func (c *Client) Context() context.Context {
	c.mu.Lock()
	defer c.mu.Unlock()

	return c.ctx
}
