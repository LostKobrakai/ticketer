defmodule TicketDispenserTest do
  use ExUnit.Case
  doctest TicketDispenser

  defp match_tickets(%Ticket{id: id, event: event}, %Ticket{} = ticket_b) do
    match?(%{id: ^id, event: ^event}, ticket_b)
  end

  test "the correct state returned" do
    {:ok, pid} = TicketDispenser.start_link({10, nil, 1001})

    assert {:ok, %{free: _, taken: _}} = TicketDispenser.state(pid)
  end

  test "the correct initialization" do
    {:ok, pid} = TicketDispenser.start_link({10, nil, 1001})

    {:ok, %{free: free, taken: taken}} = TicketDispenser.state(pid)

    assert 10 == Enum.count(free)
    assert 0 == Enum.count(taken)
  end

  test "the correct behavour for reserving a ticket" do
    {:ok, pid} = TicketDispenser.start_link({10, nil, 1001})

    {:ok, ticket} = TicketDispenser.reserve(pid)

    {:ok, %{free: free, taken: taken}} = TicketDispenser.state(pid)

    assert false === Enum.any?(free, &(match_tickets(&1, ticket)))
    assert true === match_tickets(List.first(taken), ticket)
    assert 9 == Enum.count(free)
    assert 1 == Enum.count(taken)
  end

  test "return an error if all tickets are gone" do
    {:ok, pid} = TicketDispenser.start_link({1, nil, 1001})

    {:ok, _ticket} = TicketDispenser.reserve(pid)

    assert {:error, _} = TicketDispenser.reserve(pid)
  end

  test "simulate load" do
    {:ok, pid} = TicketDispenser.start_link({11000, nil, 1001})

    result = 1..40000
      |> Stream.map(fn(_) -> Task.async(fn -> TicketDispenser.reserve(pid) end) end)
      |> Enum.map(fn(task) -> Task.await(task) end)

    assert 11000 === Enum.count(result, &(match?({:ok, _}, &1)))
    assert 40000 - 11000 === Enum.count(result, &(match?({:error, _}, &1)))
  end
end
