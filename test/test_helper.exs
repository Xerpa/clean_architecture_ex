ExUnit.configure(
  capture_log: true,
  formatters: [JUnitFormatter, ExUnit.CLIFormatter]
)

ExUnit.start()
