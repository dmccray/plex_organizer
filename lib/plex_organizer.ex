defmodule PlexOrganizer do
	def main(args) do
		args |> parse_args |> process
	end

	def process([]) do
		#No Arguments
		build_file_list(System.cwd(), System.cwd())
	end

	def process(options) do
		#Arguments
		build_file_list(options[:source], options[:destination])
	end

	def build_file_list(src_directory, dest_directory) do
		#File.cd!("/User/Dee/workspace")
		#files = File.ls!(Path.absname(src_directory, dest_directory))
		#Enum.each(files, &(PlexNameTransform.match_series(&1)))

		File.ls!(Path.absname(dest_directory) <> "/TV Shows") 
		|> 	Stream.filter(&(not String.starts_with?(&1, ".")))  #filter out hidden files
		|> 	Enum.each(&(PlexNameTransform.match_content(:series, src_directory, dest_directory, &1)))

	end

	defp parse_args(args) do
		{options, _, _} = OptionParser.parse(args,
			switches: [source: :string, destination: :string]
		)

		options
	end
end
