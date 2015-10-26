defmodule PlexNameTransform do
	def match_content(:series, src_directory, dest_directory, show) do
		show_regex = String.replace(show, ~r/\(\d\d\d\d\)/, "")		#remove year
						|> String.strip								#strip whitespace
						|> String.replace(" ", "(\\s|\\S)")   		#add regular expressions
						|> add_parens								#add parenthesis around regular expression
						|> Regex.compile							#create regular expression from string
						|> elem(1)									#get the regex from the tuple

		file = File.ls!(Path.absname(src_directory))
		Enum.each(file, &(IO.puts("#{&1}: #{show} - #{String.match?(&1, show_regex)}")))

		#need to deal with season number as well
		#need to call a new function to check if file or directory, if regex matched, get file (either from directory or file itself), and copy to destination folder
		#if folder doesn't exist write to error log file (have to create structure in order for program to work)
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
		
		Enum.each(file, &(IO.puts(&1)))

	end

	defp create_destination(:movie, src_path) do
	end	

	defp match_regex(:series, file_name, show, regex) do

	end

	defp add_parens(str) do
		"(" <> str <> ")"
	end


end




