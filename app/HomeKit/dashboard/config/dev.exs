import Config

config :dashboard, DashboardWeb.Endpoint,
  http: [ip: {127, 0, 0, 1}, port: String.to_integer(System.get_env("PORT") || "4000")],
  check_origin: false,
  code_reloader: true,
  debug_errors: true,
  secret_key_base: "DfAQ8Cto2A0Z0znfh6+Z4t4MRwomcCzw/j8JQ9a1ToAoACL4cF/rZ7c+KFOKDrI0",
  watchers: [
    esbuild: {Esbuild, :install_and_run, [:dashboard, ~w(--sourcemap=inline --watch)]},
    tailwind: {Tailwind, :install_and_run, [:dashboard, ~w(--watch)]}
  ]

config :dashboard, DashboardWeb.Endpoint,
  live_reload: [
    web_console_logger: true,
    patterns: [
      ~r"priv/static/(?!uploads/).*(js|css|png|jpeg|jpg|gif|svg)$",
      ~r"priv/gettext/.*(po)$",
      ~r"lib/dashboard_web/(?:controllers|live|components|router)/?.*\.(ex|heex)$"
    ]
  ]

config :dashboard, dev_routes: true

config :dashboard, Dashboard.Repo,
  database: "../../Database/HomeKit.db",
  pool_size: 10,
  journal_mode: :wal,
  timeout: 15_000

config :logger, :default_formatter, format: "[$level] $message\n"

config :phoenix, :stacktrace_depth, 20

# Initialize plugs at runtime for faster development compilation
config :phoenix, :plug_init_mode, :runtime

config :phoenix_live_view,
  debug_heex_annotations: true,
  debug_attributes: true,
  enable_expensive_runtime_checks: true

config :swoosh, :api_client, false
