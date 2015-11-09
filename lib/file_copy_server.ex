defmodule FileCopyServer do
	use Genserver

	defmodule State do
		defstruct file_copy_count: 0, file_exist_count: 0, file_delete_count: 0
	end

	def start_link do
		GenServer.start_link(__MODULE__, [], [{:name, __MODULE__}])
	end

	def init([]) do
		{:ok, %State{}}
	end

	def handle_call(file, src, dest, _from, state) do
		#need internal function to handle the copy
	end

	#internal function
	
end

	
