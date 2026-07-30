{ pkgs, ... }:

{
  # Lean library shell: pin Elixir/OTP to match .tool-versions + CI,
  # and ship dolt for beads (bd) embedded DB bootstrap/recovery.

  languages.elixir = {
    enable = true;
    package = pkgs.beam.packages.erlang_27.elixir_1_17;
  };

  packages = [
    pkgs.git
    pkgs.gnumake
    pkgs.gcc
    # Keep `erl` on PATH aligned with languages.elixir (system profile may
    # otherwise shadow with a different OTP).
    pkgs.beam.packages.erlang_27.erlang
    # Backend for beads (bd). bd's embedded dolt DB is hydrated from
    # git-tracked .beads/*.jsonl via `bd bootstrap` on fresh clones.
    pkgs.dolt
  ];
}
