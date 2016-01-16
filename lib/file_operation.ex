defmodule FileOperation do
	require Lager

	def operation(file, opp_count) do
		receive do
			{:copy, {from, file_orig, file_new}} ->
				copy(file_orig, file_new)
				operation(file, opp_count + 1)

			{:verify, {from, file_orig, file_new}} ->
				verify(file_orig, file_new)
				operation(file, opp_count + 1)

			{:clean, {from, file_hash, file_orig, trash}} ->
			 #File.rename(Path.absname(src_path <> "/" <> src_file_or_folder), Path.absname(trash_file))
				clean(file_orig, trash)
				send(from, {:done, {self(), file_hash}})      #after cleaning file send message to parent process to kill
				operation(file, opp_count + 1)
		end
	end

	defp copy(file_orig, file_new) do
		Lager.info("Copying: #{file_orig} To: #{file_new}")
		File.copy!(file_orig, file_new)						#copy to new destination
	end

	#not using
	defp verify(file_orig, file_new) do
		#Lager.info("Verifying #{file_orig} and #{file_new}")
		#IO.puts "***** Verified: #{gen_md5(file_orig) == gen_md5(file_new)}: #{gen_md5(file_orig)}  #{gen_md5(file_new)} ******"
	end

	defp clean(file_orig, trash) do
		Lager.info("Moving #{file_orig} To #{trash}")
		File.copy!(file_orig, trash)							#copy to trash

		if(Path.dirname(file_orig) != "/Volumes/FreeAgent/torrent_complete") do
			Lager.warning("Removing Directory: #{Path.dirname(file_orig)}")
			File.rm_rf!(Path.dirname(file_orig))				#delete directory if not at torrent_complete
		else
			Lager.warning("Removing File: #{file_orig}")
			File.rm_rf!(file_orig)									#otherwise just delete file
		end
	end
end
