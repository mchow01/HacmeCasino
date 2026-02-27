# Hacme Casino

A deliberately vulnerable web application for security training. Originally created by Foundstone, this is a Ruby on Rails casino site riddled with intentional security flaws — SQL injection, XSS, broken authentication, insecure direct object references, and more.

> **Warning:** This application contains intentional security vulnerabilities. Run it only in an isolated environment. Do not expose it to the internet.

## Quick Start

```bash
docker-compose up --build
```

Open http://localhost:3000, register an account, and start exploring.

On first run the container creates a fresh SQLite3 database. There are no pre-seeded users — register through the UI.

## Stack

| Component | Version |
|-----------|---------|
| Ruby | 1.8.7-p374 |
| Rails | 1.2.6 |
| Database | SQLite 3 |
| Web server | WEBrick |

The app predates Bundler. Gem management is handled entirely inside the Docker image.

## Games

- **Blackjack** — `/blackjack`
- **Video Poker** — `/video_poker`

Each game uses chips tied to your user account. Chips are tracked in the database and manipulated via the lobby and account options pages.

## What to Look For

The app is a learning target for finding and exploiting web vulnerabilities. Some starting points:

- **`User.authenticate`** in `app/app/models/user.rb` — how does it build its SQL query?
- **`transfer_chips`** in `app/app/controllers/account_controller.rb` — what does `params['login'][0]` actually accept?
- **`cash_out`** in `app/app/controllers/account_controller.rb` — there is a hardcoded condition. What account and parameters trigger it?
- **Session handling** in `app/lib/login_system.rb` — what is stored in the session and how is it trusted?
- **`redirect_back_or_default`** — what does it do with `session['return-to']`?

## Repository Layout

```
app/              Rails 1.2.6 source (upstream as-is, with one config patch)
Dockerfile        Ubuntu 16.04 + Ruby 1.8.7 compiled from source
entrypoint.sh     DB initialisation + server start
docker-compose.yml
```

## Building Without Compose

```bash
docker build -t hacmecasino .
docker run --rm -p 3000:3000 hacmecasino
```

## Upstream Source

https://github.com/spinkham/Hacme-Casino
