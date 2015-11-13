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
		|> 	Enum.each(&(match_content(:series, src_directory, dest_directory, &1)))

	end

	defp parse_args(args) do
		{options, _, _} = OptionParser.parse(args,
			switches: [source: :string, destination: :string]
		)

		options
	end

	defp match_content(:series, src_directory, dest_directory, show) do
		show_regex = define_regex(show)
		file_list = File.ls!(Path.absname(src_directory))

		if(file_list != []) do
			#spawn parent process for managing files to copy
			Process.register(spawn(FileManager, :manage, [0]), :FileManager)
		end
		
		Enum.each(file_list, &(match_show(&1, show, show_regex, src_directory, dest_directory)))
	end

	defp match_content(:movie, src_directory, dest_directory, show) do
		#tab to start automating movies
	end

	defp match_show(file, show, regex, src, dest) do
		if String.match?(String.upcase(file),regex) do
			{season, episode, seas_epi_tag} = get_season_episode(:series, file)
			show_folder = find_destination(:series, dest, show, season)

			#IO.puts("Destination: #{dest}/TV Shows/#{show}/#{season} Show: #{show} - #{seas_epi_tag} Exists?: #{exists?(:series, "#{dest}/TV Shows/#{show}/#{season}", "#{show} - #{seas_epi_tag}")}")
			#file_or_folder returns the file to be copied
			
			if exists?(:series, "#{dest}/TV Shows/#{show}/#{season}", "#{show} - #{seas_epi_tag}") do
				IO.puts("#{show} - #{seas_epi_tag} exists. Moving #{src}/#{file} to trash.") #log move to Trash
				#recycle(src, file)	#move source to recycle bin
			else
				##{:ok, pid} = FileCopyServer.start_link(file)           #starting new OTP process
				#GenServer.call(pid, {file, src, dest})     #Synchronous call to copy file	
			
			  #send message to manager to create a child process for a single file
			  send(:FileManager, {:create, {self(), file}})

			  :timer.sleep(1000)
				
			  #send message to manager to process file
			  send(:FileManager, {:process,
				  								 {self(),
					  								file,
						  							"#{src}/#{file}",
							  						"#{dest}/TV Shows/#{show}/#{season}/#{show} - #{seas_epi_tag}",
								  					"/Users/dmccray/.Trash"
									  			 }})
				
				#IO.puts("Copy of #{show_folder}/#{season}/#{show} - #{seas_epi_tag} Verified.")												#log verification of copy
				#move source to recycle bin
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

	defp copy_file(src_path, src_file) do
	end

	#return true or false after copy
	defp verify_copy(src_path, src_file) do
	end

	defp add_parens(str) do
		"(" <> str <> ")"
	end
end
