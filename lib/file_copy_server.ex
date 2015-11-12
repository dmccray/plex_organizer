defmodule FileCopyServer do
	use GenServer

	defmodule State do
		defstruct file_copy_count: 0, file_exist_count: 0, file_delete_count: 0
	end

	def start_link(file) do
		GenServer.start_link(__MODULE__ , [], [{:name, String.to_atom("Elixir.FileCopyServer.#{file}")}])
	end

	def init([]) do
		{:ok, %State{}}
	end

	def handle_call(request, _from, state) do
		file = elem(request, 0)
		source = elem(request, 1)
		destination = elem(request, 2)
    process = elem(_from, 0)
		
		reply = {:ok, copy_file(file, source, destination, process)}
		new_state = %State{file_copy_count: state.file_copy_count + 1}

		{:reply, reply, new_state}
	end

	def handle_cast() do
	end
	
	#internal function
	def copy_file(file, src, dest, pid) do
		#name = GenServer.whereis(self())
		name = String.to_atom("Elixir.FileCopyServer.#{file}")
		IO.puts("Process [#{name}] - *Synchronous* Copying: #{src}/#{file} To: #{dest}")
	end
		
end

	
