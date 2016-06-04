defmodule WorkerTest do
  use ExUnit.Case

  setup do
    table = :ets.new(:urls, [:set, :public])

    {:ok, worker1} = Shortener.Worker.start_link(table)
    {:ok, worker2} = Shortener.Worker.start_link(table)

    {:ok, table: table, w1: worker1, w2: worker2}
  end

  test "reading a shortened url from any worker", state do
    %{table: table, w1: worker1, w2: worker2} = state
    :ets.insert(table, {"nf", "https://nephroflow.com"})

    assert {:ok, "https://nephroflow.com"} ==
      Shortener.Worker.url(worker1, "nf")

    assert {:ok, "https://nephroflow.com"} ==
      Shortener.Worker.url(worker2, "nf")
  end

  test "shortening a url", %{w1: pid} do
    :ok = Shortener.Worker.shorten(pid, "https://nephroflow.com", "nf")
    assert {:ok, "https://nephroflow.com"} == Shortener.Worker.url(pid, "nf")
  end

  test "finding a url that does not exist", %{w1: pid} do
    assert :error == Shortener.Worker.url(pid, "nf")
  end

  test "shortening to an existing alias", %{w1: pid} do
    :ok = Shortener.Worker.shorten(pid, "https://nephroflow.com", "nf")
    assert {:error, :dupalias} == Shortener.Server.shorten(pid, "https://nephroflow.com", "nf")
  end
end
