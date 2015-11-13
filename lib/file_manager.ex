defmodule FileManager do
	def manage(process_count) do
		receive do
			{:create, {from, file}} ->
				if (Process.whereis(String.to_atom(file)) == nil) do
					#spawn process and register its name as the file name the process will manage
					Process.register(spawn(FileOperation, :operation, [file, 1]), String.to_atom(file))
				end
				manage(process_count + 1)
		
			{:process, {from, file, file_orig, file_new, trash}} ->
				if(Process.whereis(String.to_atom(file)) != nil) do
					send(String.to_atom(file), {:copy, {self(), file_orig, file_new}})       #copy
					send(String.to_atom(file), {:verify, {self(), file_orig, file_new}})     #verify
					send(String.to_atom(file), {:clean, {self(), file_orig, trash}})         #cleanup
				end
				manage(process_count)
			
			{:done, {from, file}} ->
				#kill process
				#Process.exit(from, :kill)
				IO.puts("Killing process: #{file}")
				manage(process_count - 1)
		end
	end
end
