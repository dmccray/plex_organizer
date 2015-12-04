defmodule FileManager do
	def manage(process_count) do
		receive do
			{:create, {from, file, file_hash}} ->
				if (Process.whereis(String.to_atom(file_hash)) == nil) do
					#spawn process and register its name as the file name the process will manage
					Process.register(spawn(FileOperation, :operation, [file, 1]), String.to_atom(file_hash))
					IO.puts("Creating process: #{file_hash}")
				end
				manage(process_count + 1)
		
			{:process, {from, file_hash, file_orig, file_new, trash}} ->
				if(Process.whereis(String.to_atom(file_hash)) != nil) do
					send(String.to_atom(file_hash), {:copy, {self(), file_orig, file_new}})       #copy
					send(String.to_atom(file_hash), {:verify, {self(), file_orig, file_new}})     #verify
					send(String.to_atom(file_hash), {:clean, {self(), file_orig, trash}})         #cleanup
				end
				manage(process_count)

			{:clean, {from, file_hash, file_orig, trash}} ->
				if(Process.whereis(String.to_atom(file_hash)) != nil) do
					send(String.to_atom(file_hash), {:clean, {self(), file_hash, file_orig, trash}})         #cleanup
				end
				manage(process_count)
			
			{:done, {from, file_hash}} ->
				#kill process
				Process.exit(from, :kill)
				IO.puts("Killing process: #{from} - #{file_hash}")
				manage(process_count - 1)
		end
	end
end
