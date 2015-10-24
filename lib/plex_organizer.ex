defmodule PlexOrganizer do
	def main(args) do
		IO.puts("It has begun")

		args |> parse_args |> process
	end

	def process([]) do
		IO.puts("No arguments given")
	end

	def process(options) do
		IO.puts("Hello #{options[:name]}")
	end

	defp parse_args(args) do
		{options, _, _} = OptionParser.parse(args,
			switches: [name: :string, time: :string]
		)

		options
	end
end
