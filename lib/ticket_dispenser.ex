defmodule TicketDispenser do
  use GenServer

  def start_link(state, opts \\ []) do
    GenServer.start_link(__MODULE__, state, opts)
  end

  def reserve() do
    GenServer.call(__MODULE__, :reserve)
  end

  def state() do
    GenServer.call(__MODULE__, :state)
  end

  def return(%Ticket{id: id}) do
    GenServer.call(__MODULE__, {:return, id})
  end

  def return(id) do
    GenServer.call(__MODULE__, {:return, id})
  end

  # Callbacks

  def init({amount, timeout, name}) do
    tickets = 1..amount |> Enum.map(&(%Ticket{id: &1, event: name}))

    {:ok, %{free: tickets, taken: [], timeout: timeout}}
  end

  def handle_call(:reserve, _from, %{free: tickets, taken: taken} = state) do
    case Enum.split(tickets, 1) do
      {[ticket], free} -> 
        ticket = %Ticket{ticket | taken_at: DateTime.utc_now()}
        state = %{
          free: free, 
          taken: [ticket | taken]
        }
        {:reply, {:ok, ticket}, state}
      _ -> {:reply, {:error, :noticketsleft}, state}
    end
  end

  def handle_call(:state, _from, state) do
    {:reply, {:error, state}, state}
  end

  def handle_call({:return, id}, _from, %{free: tickets, taken: taken} = state) do
    case Enum.find(taken, &match?(%Ticket{id: ^id}, &1)) do
      nil -> {:reply, {:error, :ticketnottaken}, state}
      ticket -> 
        state = %{
          free: [%Ticket{ticket | taken_at: nil} | tickets], 
          taken: List.delete(taken, ticket)
        }
        {:reply, {:ok, id}, state}
    end
  end
end
