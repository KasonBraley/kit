//go:build mage

package main

import (
	"context"
	"fmt"
	"os"

	"dagger.io/dagger"
	"github.com/KasonBraley/kit/ci/util"
	"github.com/magefile/mage/mg"
)

type linter interface {
	Lint(context.Context) error
}

// Lint runs all linters
func Lint(ctx context.Context) error {
	return Go{}.Lint(ctx)
}

// Test runs all tests
func Test(ctx context.Context) error {
	return Go{}.Test(ctx)
}

type Go mg.Namespace

func (t Go) Lint(ctx context.Context) error {
	c, err := dagger.Connect(ctx, dagger.WithLogOutput(os.Stderr))
	if err != nil {
		return err
	}
	defer c.Close()

	c = c.Pipeline("go").Pipeline("lint")

	_, err = c.Container().
		From("golangci/golangci-lint:v1.53.2-alpine").
		WithMountedDirectory("/app", util.RepositoryGoCodeOnly(c)).
		WithWorkdir("/app").
		WithExec([]string{"golangci-lint", "run", "-v", "--timeout", "5m"}).
		Sync(ctx)

	return err
}

func (t Go) Test(ctx context.Context) error {
	c, err := dagger.Connect(ctx, dagger.WithLogOutput(os.Stderr))
	if err != nil {
		return err
	}
	defer c.Close()

	c = c.Pipeline("go").Pipeline("test")

	output, err := util.GoBase(c).
		WithWorkdir("/app").
		WithExec([]string{"go", "test", "-v", "./..."}).
		Stdout(ctx)
	if err != nil {
		err = fmt.Errorf("test failed: %w\n%s", err, output)
	}
	return err
}
