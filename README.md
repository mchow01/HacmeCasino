# Hacme Casino

A deliberately vulnerable web application for security training. Originally created by Foundstone, this is a Ruby on Rails casino site riddled with intentional security flaws — SQL injection, XSS, broken authentication, insecure direct object references, and more.

> **Warning:** This application contains intentional security vulnerabilities. Run it only in an isolated environment. Do not expose it to the internet.

## Quick Start

```bash
docker-compose up --build
```

Open http://localhost:3000, register an account, and start exploring.

The image ships a pre-seeded SQLite3 database. Three accounts are available on first boot:

| login | password | chips |
|-------|----------|-------|
| `andy_aces` | `Password1` | 100,000 |
| `bobby_blackjack` | `Password1` | 10,000 |
| `crystal_cardshark` | `Password1` | 10,000 |

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

## Apple Silicon (M-series Macs)

The image is pinned to `linux/amd64` because Ruby 1.8.7's `configure` script does not recognise ARM64. Docker Desktop on Apple Silicon runs the x86_64 image via Rosetta 2 with no extra steps on your end.

Before building, confirm this setting is enabled in Docker Desktop:
**Settings → General → "Use Rosetta for x86_64/amd64 emulation on Apple Silicon"**

Then build and run as normal:

```bash
docker-compose up --build
```

## Building Without Compose

```bash
docker build -t hacmecasino .
docker run --rm -p 3000:3000 hacmecasino
```

## Upstream Source

https://github.com/spinkham/Hacme-Casino
