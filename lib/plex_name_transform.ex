defmodule PlexNameTransform do
	def match_content(:series, src_directory, dest_directory, show) do
		show_regex = define_regex(show)
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

			#IO.puts("Destination: #{dest}/TV Shows/#{show}/#{season} Show: #{show} - #{seas_epi_tag} Exists?: #{exists?(:series, "#{dest}/TV Shows/#{show}/#{season}", "#{show} - #{seas_epi_tag}")}")
			#file_or_folder returns the file to be copied

			#to help learn about process I should implement a "master" process that will spawn processes for each file to copy
			#each spawned copy process will pass a message back to the "master" process once it has completed successfully
			#the "master" process will then spawn a process to clean or mv the orginal file to the Recycle bin
			#get some practice with concurrency
			if exists?(:series, "#{dest}/TV Shows/#{show}/#{season}", "#{show} - #{seas_epi_tag}") do
				IO.puts("#{show} - #{seas_epi_tag} exists. Moving #{src}/#{file} to trash.") #log move to Trash
				#recycle(src, file)	#move source to recycle bin
			else 
				#copy source to destination
				IO.puts("Copying #{src}/#{file_or_folder(src, file)} to #{show_folder}/#{season}/#{show} - #{seas_epi_tag}") 				#log copy to destination
				#verify copy
				IO.puts("Copy of #{show_folder}/#{season}/#{show} - #{seas_epi_tag} Verified.")												#log verification of copy
				#move source to recycle bin
				IO.puts("#{show} - #{seas_epi_tag} copied. Moving #{src}/#{file} to trash.") 												#log move to Trash#log move to trash
			end
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

	#returns file to copy
	defp file_or_folder(path, file) do
		if (File.dir?(path <> "/" <> file)) do
			potential_files =  File.ls!(Path.absname(path <> "/" <> file))
			file_to_copy = List.foldl(potential_files, {"", 0}, 															#tuple of file and largest size as accumulator for fold fn
								fn(pf, largest_so_far_t) -> 																#anonymous function to find largest file recursively
									fstat = File.stat!(Path.absname(path <> "/" <> file <> "/" <> pf))
									if(fstat.size > elem(largest_so_far_t,1)) do 
										{pf, fstat.size}
									else
										largest_so_far_t
									end
								end
							) 
			elem(file_to_copy, 0)
		else
			file
		end
	end

	#tests that the file doesn't already exist in location
	defp exists?(:series, path, episode) do
		episode_regex = define_regex(episode)										
		file_exists = List.foldl(File.ls!(Path.absname(path)), :false,
							fn(chk_file, found) ->
								if (String.match?(String.upcase(chk_file), episode_regex)) do
									:true
								else
									found
								end
							end
						)
	end

	defp define_regex(str) do
		String.upcase(str)											#make string uppercase to match uppercase filename
			|> String.replace(~r/\(\d\d\d\d\)/, "(\\d\\d\\d\\d)?")	#remove year
			|> String.strip											#strip whitespace
			|> String.replace(" ", "(\\s|\\S)*")   					#add regular expressions
			|> add_parens											#add parenthesis around regular expression
			|> Regex.compile										#create regular expression from string
			|> elem(1)												#get the regex from the tuple
	end

	defp recycle(src_path, src_file_or_folder) do 
		trash_file = "/Users/dmccray/.Trash/#{src_file_or_folder}"
		File.rename(Path.absname(src_path <> "/" <> src_file_or_folder), Path.absname(trash_file))
	end

	defp copy_file(src_path, src_file) do
	end

	#return true or false after copy
	defp verify_copy(src_path, src_file) do 
	end

	defp add_parens(str) do
		"(" <> str <> ")"
	end
end


