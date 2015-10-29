defmodule PlexNameTransform do
	def match_content(:series, src_directory, dest_directory, show) do
		show_regex = String.replace(show, ~r/\(\d\d\d\d\)/, "")		#remove year
						|> String.strip								#strip whitespace
						|> String.replace(" ", "(\\s|\\S)")   		#add regular expressions
						|> add_parens								#add parenthesis around regular expression
						|> String.upcase							#make string uppercase to match uppercase filename
						|> Regex.compile							#create regular expression from string
						|> elem(1)									#get the regex from the tuple

		file_list = File.ls!(Path.absname(src_directory))
		Enum.each(file_list, &(match_show(&1, show, show_regex, src_directory, dest_directory)))
	end

	def match_content(:movie, src_directory, dest_directory, show) do
		#tab to start automating movies
	end

	defp match_show(file, show, regex, src, dest) do
		if String.match?(String.upcase(file),regex) do
			{season, episode, seas_epi_tag} = get_season_episode(:series, file)
			show_folder = find_destination(:series, dest, show, season)

			IO.puts(show_folder)

			#check if dest file/show already exists
			#check source is file. if directory find file; i.e. fn that returns the file given the source
			#copy file
			#verify copied file
			#move source to recycle bin

		end

	end
	
	defp series?(src_path) do
		Regex.run(~r/S\d\dE\d\d/, src_path) != nil
	end

	defp movie?(src_path) do
		Regex.run(~r/\(\d\d\d\d\)/, src_path) != nil
	end

	defp get_season_episode(:series, file) do
		[se_tag | tl] = Regex.run(~r/S\d\dE\d\d/, file)
		[hd | tl] = String.split(se_tag, ["S","E"])
		[car | [caar| cdr]] = tl

		{"Season #{String.lstrip(car,?0)}","Episode #{String.lstrip(caar,?0)}", se_tag}
	end

	defp find_destination(:series, plex_media_path, show, season) do
		path = Path.absname(plex_media_path<>"/TV Shows")
		folders = File.ls!(path)
		[show_folder | tl] = Enum.filter(folders,&(String.upcase(&1) == String.upcase(show)))
		show_folder = Path.join(path, show_folder)

		if File.dir?(show_folder), do: show_folder, else: nil
	end

	defp exists?(:series, show, season) do
	end

	defp add_parens(str) do
		"(" <> str <> ")"
	end

end




