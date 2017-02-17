defmodule TicketerSupervisor do
	use Supervisor

	@events [
		{:slot1, {10, nil, "Slot 1"}},
		{:slot2, {10, nil, "Slot 2"}},
		{:slot3, {10, nil, "Slot 3"}},
		{:slot4, {10, nil, "Slot 4"}},
		{:slot5, {10, nil, "Slot 5"}},
		{:slot6, {10, nil, "Slot 6"}},
		{:slot7, {10, nil, "Slot 7"}},
		{:slot8, {10, nil, "Slot 8"}},
		{:slot9, {10, nil, "Slot 9"}}
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