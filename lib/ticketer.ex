defmodule Ticketer do
	use Application

	def start(_type, _args) do
		IO.puts "Starting up..."
		TicketerSupervisor.start_link()
	end
end