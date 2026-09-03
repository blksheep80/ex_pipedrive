# Declared roots for the transitive dead-code analyzer (ExPipedrive).
#
# A root is code reachable from outside this repository — downstream Hex users,
# the BEAM, Mix CLI, or runtime wiring static analysis cannot follow.
#
# THIS FILE IS THE RATCHET. When the verification gate proves a cluster is live,
# add the entry point here with the reason — do not patch the analyzer.

%{
  # Published Hex package: these paths cannot be proven dead from inside the repo.
  # Unused-public-API findings stay advisory; removing one is a breaking change.
  public_api: [
    "lib/ex_pipedrive.ex",
    "lib/ex_pipedrive/**/*.ex"
  ],

  # Reachable but not visible to the graph. Paths may contain globs.
  # Mix tasks under lib/mix/ and config/*.exs modules are rooted automatically.
  roots: [
    {"test/support/fake_pipedrive_server.ex",
     "Cowboy test HTTP server started by ExUnit cases"},
    {"test/support/fake_*_api_handler.ex",
     "FakePipedriveServer route handlers wired at test runtime"},
    {"lib/ex_pipedrive/middleware/*.ex",
     "Tesla middleware selected via Client opts (:retry, :telemetry, :middleware)"}
  ]
}
