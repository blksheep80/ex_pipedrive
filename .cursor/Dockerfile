FROM hexpm/elixir:1.17.2-erlang-27.0.1-debian-bookworm-slim

RUN apt-get update \
    && apt-get install -y --no-install-recommends \
        git \
        build-essential \
        curl \
        ca-certificates \
    && rm -rf /var/lib/apt/lists/*

# Cursor cloud agents expect an unprivileged user named ubuntu.
RUN useradd -m -s /bin/bash ubuntu
USER ubuntu
WORKDIR /home/ubuntu

ENV MIX_ENV=test
