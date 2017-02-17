defmodule TicketerSupervisor do
	use Supervisor

	@events [
		{:slot1, {10, nil, 1000}},
		{:slot2, {10, nil, 1001}},
		{:slot3, {10, nil, 1002}},
		{:slot4, {10, nil, 1003}},
		{:slot5, {10, nil, 1004}},
		{:slot6, {10, nil, 1005}},
		{:slot7, {10, nil, 1006}},
		{:slot8, {10, nil, 1007}},
		{:slot9, {10, nil, 1008}}
	]

	def start_link do
		Supervisor.start_link(__MODULE__, [], name: __MODULE__)
	end

	def init([]) do
		children = for {name, state} <- @events do
			worker(TicketDispenser, [state, [name: name]], [id: name])
		end

		supervise(children, strategy: :one_for_one)
	end
end