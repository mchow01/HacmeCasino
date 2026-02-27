FROM ubuntu:16.04

ENV DEBIAN_FRONTEND=noninteractive \
    RAILS_ENV=development

# Build dependencies (Ubuntu 16.04 ships OpenSSL 1.0.2 — compatible with Ruby 1.8.7)
RUN apt-get update && apt-get install -y \
    build-essential wget ca-certificates \
    zlib1g-dev libssl-dev libreadline-dev libgdbm-dev \
    libsqlite3-dev sqlite3 \
    && rm -rf /var/lib/apt/lists/*

# ── Ruby 1.8.7-p374 ──────────────────────────────────────────────────────────
RUN wget https://cache.ruby-lang.org/pub/ruby/1.8/ruby-1.8.7-p374.tar.gz -O /tmp/ruby.tar.gz \
    && tar xzf /tmp/ruby.tar.gz -C /tmp \
    && cd /tmp/ruby-1.8.7-p374 \
    && ./configure --prefix=/usr/local \
    && make -j$(nproc) \
    && make install \
    && rm -rf /tmp/ruby-1.8.7-p374 /tmp/ruby.tar.gz

# ── RubyGems 1.8.25 (latest that supports Ruby 1.8.x) ───────────────────────
RUN wget https://rubygems.org/rubygems/rubygems-1.8.25.tgz -O /tmp/rubygems.tgz \
    && tar xzf /tmp/rubygems.tgz -C /tmp \
    && cd /tmp/rubygems-1.8.25 \
    && ruby setup.rb \
    && rm -rf /tmp/rubygems-1.8.25 /tmp/rubygems.tgz

# ── Download .gem files via system wget (avoids Ruby 1.8 TLS limitations) ────
RUN mkdir /gems && cd /gems \
    && for gem in \
        rake-0.7.3 \
        activesupport-1.4.4 \
        activerecord-1.15.6 \
        builder-2.1.2 \
        cgi_multipart_eof_fix-2.5.0 \
        actionpack-1.13.6 \
        tmail-1.2.7.1 \
        actionmailer-1.3.6 \
        actionwebservice-1.2.6 \
        rails-1.2.6 \
        sqlite3-ruby-1.2.4 \
    ; do \
        wget https://rubygems.org/downloads/${gem}.gem -O ${gem}.gem; \
    done

# ── Install gems in dependency order ─────────────────────────────────────────
RUN gem install /gems/rake-0.7.3.gem                  --no-rdoc --no-ri --ignore-dependencies \
    && gem install /gems/activesupport-1.4.4.gem      --no-rdoc --no-ri --ignore-dependencies \
    && gem install /gems/activerecord-1.15.6.gem      --no-rdoc --no-ri --ignore-dependencies \
    && gem install /gems/builder-2.1.2.gem            --no-rdoc --no-ri --ignore-dependencies \
    && gem install /gems/cgi_multipart_eof_fix-2.5.0.gem --no-rdoc --no-ri --ignore-dependencies \
    && gem install /gems/actionpack-1.13.6.gem        --no-rdoc --no-ri --ignore-dependencies \
    && gem install /gems/tmail-1.2.7.1.gem            --no-rdoc --no-ri --ignore-dependencies \
    && gem install /gems/actionmailer-1.3.6.gem       --no-rdoc --no-ri --ignore-dependencies \
    && gem install /gems/actionwebservice-1.2.6.gem   --no-rdoc --no-ri --ignore-dependencies \
    && gem install /gems/rails-1.2.6.gem              --no-rdoc --no-ri --ignore-dependencies \
    && gem install /gems/sqlite3-ruby-1.2.4.gem       --no-rdoc --no-ri

# ── Application ──────────────────────────────────────────────────────────────
WORKDIR /app
COPY app/ /app/

# Switch from legacy SQLite 2 adapter name to SQLite 3
# Rails 1.2.6 uses `dbfile:` key for both adapters — only the adapter name changes
RUN sed -i 's/adapter: sqlite$/adapter: sqlite3/' config/database.yml \
    && rm -f db/hacmecasino_development.db db/hacmecasino_test.db

# Ensure writable runtime directories exist
RUN mkdir -p log tmp/sessions tmp/cache

COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

EXPOSE 3000
ENTRYPOINT ["/entrypoint.sh"]
