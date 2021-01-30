package database

import (
	"context"

	"github.com/go-redis/redis/v8"
)

var (
	Ctx context.Context
	DB  *redis.Client
)
