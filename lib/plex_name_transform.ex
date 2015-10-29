defmodule PlexNameTransform do
	def match_content(:series, src_directory, dest_directory, show) do
		show_regex = String.replace(show, ~r/\(\d\d\d\d\)/, "")		#remove year
						|> String.strip								#strip whitespace
						|> String.replace(" ", "(\\s|\\S)")   		#add regular expressions
						|> add_parens								#add parenthesis around regular expression
						|> String.upcase							#make string uppercase to match uppercase filename
						|> Regex.compile							#create regular expression from string
						|> elem(1)									#get the regex from the tuple

		file = File.ls!(Path.absname(src_directory))
		
		{season, episode, seas_epi_tag} = get_season_episode(:series, file)

		Enum.each(file, &(IO.puts("#{&1}: #{show} - #{String.match?(String.upcase(&1), show_regex)}")))



		#case if match
			#get and translate season
			#find destination folder for show & season
			#is file or folder
			#cd inside folder if folder
			#copy file
		#else
			#write to log no destination folder

		#need to deal with season number as well
		#need to call a new function to check if file or directory, if regex matched, get file (either from directory or file itself), and copy to destination folder
		#if folder doesn't exist write to error log file (have to create structure in order for program to work)
	end

	def match_content(:movie, src_directory, dest_directory, show) do
		#tab to start automating movies
	end

	defp series?(src_path) do
		Regex.run(~r/S\d\dE\d\d/, src_path) != nil
	end

	defp match_show(file, show) do

	end

	defp movie?(src_path) do
		Regex.run(~r/\(\d\d\d\d\)/, src_path) != nil
	end

	defp find_destination(:series, src_path, dest_path) do
		
	end

	defp get_season_episode(:series, file) do
		[se_tag | tl] = Regex.run(~r/S\d\dE\d\d/, file)
		[hd | tl] = String.split(se_tag, ["S","E"])
		[car | [caar| cdr]] = tl

		{"Season #{String.lstrip(car,?0)}","Episode #{String.lstrip(caar,?0)}", se_tag}
	end

	defp exists?(:series, show, season) do
	end

	defp add_parens(str) do
		"(" <> str <> ")"
	end

end




