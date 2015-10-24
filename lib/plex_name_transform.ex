defmodule PlexNameTransform do
	def match_content(:series, src_directory, dest_directory, show) do
		IO.puts(show)
		#at this point I have the individual show
		#need to check destination and create well formed directory if it doesn't exist
		#then copy file and flag for deletion
	end

	def match_content(:movie, src_directory, dest_directory, show) do
	end

	defp series?(src_path) do
		Regex.run(~r/S\d\dE\d\d/, src_path) != nil
	end

	defp movie?(src_path) do
		Regex.run(~r/\(\d\d\d\d\)/, src_path) != nil
	end

	defp create_destination(:series, src_path, dest_path) do
		file = File.ls!(Path.absname(dest_path))
		Enum.each(file, &(IO.puts(&1)))
	end

	defp create_destination(:movie, src_path) do
	end	
end