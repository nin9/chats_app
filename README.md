# Chats app

## Setup

1- Start the services.

``` shell
docker-compose up
```

2- Create the databases.

``` shell
docker-compose exec rails_app rake db:create
```

3- Run the migrations.

``` shell
docker-compose exec rails_app rake db:migrate
```

4- Create elasticsearch index.

``` shell
docker-compose exec rails_app rake searchkick:reindex:all
```

## API

Endpoints for rails_app, serving at `localhost:3000`

| verb | route                               | body params|
|------|:------------------------------------|:-----------|
| GET  | /apps                               |            |
| POST | /apps                               | name       |
| GET  | /apps/:token                        |            |
| GET  | /apps/:app_token/chats              |            |
| GET  | /apps/:app_token/chats/:number      |            |
| GET  | /apps/:app_token/chats/:number/search?q=:search_string
| GET  | /apps/:app_token/chats/:chat_number/messages|    |
| GET  | /apps/:app_token/chats/:chat_number/messages/:number|

---
Endpoints for go_app, serving at `localhost:8000`

| verb | route                               | body params|
|------|:------------------------------------|:-----------|
| POST | /apps/:app_token/chats              |            |
| POST | /apps/:app_token/chats/:chat_number/messages|body|

---

## Design

### Chats and messages creation

- In *go_app* redis handles the chat/message number using **Incr** command, then go_workers2 pushes a job to sidekiq to create a chat/message and
a response is sent to the user with the number.

- Sidekiq is then responsible for creating the chat/message, incrementing the chats_count/messages_count and presisting the data to mysql.

- A message queue (RabbitMq, kafka, ...etc) could've been used, but since redis is a single point failure in this design, introduceing another single point of failure is not optimal, specially since the same functionality can be achieved using redis.

- For this to work I used [go_workers2](https://github.com/digitalocean/go-workers2) pacakge, which can publish jobs to sidekiq, in this way redis is used as both:

  - Generator for chat/message numbers, since redis is single threaded it's ACID complient by nature, hence we can guarantee that there will be no race  conitions in  chat/message numbers creation.
  - Communication queue between the 2 services to push jobs from go_app to sidekiq.

- Database locks are used to ensure that the chats/messages_count are correct, and transactions are used to make the 2 operations (creating the chat/message and updating the count) atomic.
