defmodule FileOperation do
	require Lager

	def operation(file, opp_count) do
		#trash_file = "/Users/dmccray/.Trash/file"

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
		#IO.puts("Copying: #{file_orig} To: #{file_new}")
	end

	defp verify(file_orig, file_new) do
		Lager.info("Verifying #{file_orig} and #{file_new}")
		#IO.puts("Verifying #{file_orig} and #{file_new}")
	end

	defp clean(file_orig, trash) do
		Lager.info("Moving #{file_orig} to #{trash}")
		#IO.puts("Moving #{file_orig} to #{trash}")
	end
end
