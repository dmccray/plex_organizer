defmodule PlexOrganizer.Mixfile do
  use Mix.Project

  def project do
    [app: :plex_organizer,
     version: "0.0.1",
     elixir: "~> 1.1",
     escript: [main_module: PlexOrganizer],
     build_embedded: Mix.env == :prod,
     start_permanent: Mix.env == :prod,
     deps: deps]
  end

  # Configuration for the OTP application
  #
  # Type "mix help compile.app" for more information
  def application do
    [applications: [:logger, :logger_file_backend]]
  end

  # Dependencies can be Hex packages:
  #
  #   {:mydep, "~> 0.3.0"}
  #
  # Or git/path repositories:
  #
  #   {:mydep, git: "https://github.com/elixir-lang/mydep.git", tag: "0.1.0"}
  #
  # Type "mix help deps" for more examples and options
  defp deps do
    [
      [{:logger_file_backend, git: "git://github.com/onkel-dirtus/logger_file_backend.git"}]
    ]
  end
end
