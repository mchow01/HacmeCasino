# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Running

```bash
docker-compose up --build   # build + start
docker-compose up           # start (after first build)
```

Access at http://localhost:3000. Register a user through the UI — no seeded accounts exist.

The entrypoint runs `rake db:schema:load` on first boot (when `db/hacmecasino_development.db` is absent), then starts WEBrick on 0.0.0.0:3000.

## Repository Layout

```
app/              Rails 1.2.6 source (cloned from upstream, as-is)
Dockerfile        Build definition
entrypoint.sh     DB init + server startup script
docker-compose.yml
```

The original source is in `app/`. Docker infrastructure lives at the repo root.

## Stack

Rails 1.2.6 · Ruby 1.8.7-p374 · SQLite 3 · WEBrick · no Bundler (pre-Bundler era)

## Architecture

**Database:** Single `users` table — `login`, `password` (SHA1 hex), `chips`, `first_name`, `last_name`. Schema in `app/db/schema.rb`.

**Auth:** `app/lib/login_system.rb` module, included by `ApplicationController`. Uses `before_filter :login_required`. Session key is `session['user']`, set to the full `User` ActiveRecord object on login.

**Games:** `BlackjackController < GameController`, `VideoPokerController < GameController`. Game state lives in `session['bjgame']` / `session['vpgame']`. Both controllers inherit chip validation from `ApplicationController#is_valid_amt?`.

**Sessions:** File-based PStore stored in `tmp/sessions/` (Rails 1.x default).

**`app/init.rb`** — Windows installer artefact. Loads `script/server` and registers an `at_exit` hook that requires the old `sqlite` gem. It is **not** called during normal startup; ignore it.

## Dockerfile Notes

- **Ubuntu 16.04** base — ships OpenSSL 1.0.2, which Ruby 1.8.7's `ext/openssl` requires. Later Ubuntu versions break the compile.
- **Gems downloaded via system `wget`** — RubyGems 1.8.x cannot negotiate TLS 1.2 with rubygems.org; system wget can. All gems are installed from local `.gem` files.
- **Gem versions are pinned:** rake-0.7.3, activesupport-1.4.4, activerecord-1.15.6, actionpack-1.13.6, actionmailer-1.3.6, actionwebservice-1.2.6, builder-2.1.2, cgi_multipart_eof_fix-2.5.0, tmail-1.2.7.1, sqlite3-ruby-1.2.4. Do not upgrade rake past 0.8.x — the Rakefile syntax is incompatible with rake 0.9+.
- **`adapter: sqlite` → `adapter: sqlite3`** — patched via `sed` in the Dockerfile. Rails 1.2.6 uses the `dbfile:` key for both adapters; only the adapter name needed changing.
- To add a gem: `wget https://rubygems.org/downloads/<name>-<ver>.gem` and add a `gem install` line in dependency order.

## Intentional Vulnerabilities

This is the training target — do not fix these flaws:

- **SQL injection** — `User.authenticate` builds its query with raw string interpolation.
- **XSS** — various views render user-supplied content without escaping.
- **Insecure direct object reference** — `account#delete` accepts an `id` param with no ownership check.
- **Open redirect** — `redirect_back_or_default` trusts `session['return-to']` which is set from the request URI.
- **Backdoor** — `account#cash_out` has a hardcoded condition on the `andy_aces` login, a specific chip amount, and a specific account number.
- **Chip manipulation** — `transfer_chips` and `change_chips` have logic that can be abused.
