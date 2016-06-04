defmodule ServerTest do
  use ExUnit.Case

  setup do
    {:ok, pid} = Shortener.Server.start_link
    {:ok, pid: pid}
  end

  test "shortening a url", %{pid: pid} do
    :ok = Shortener.Server.shorten(pid, "https://nephroflow.com", "nf")
    assert {:ok, "https://nephroflow.com"} == Shortener.Server.url(pid, "nf")
  end

  test "finding a url that does not exist", %{pid: pid} do
    assert :error == Shortener.Server.url(pid, "nf")
  end

  test "shortening to an existing alias", %{pid: pid} do
    :ok == Shortener.Server.shorten(pid, "https://nephroflow.com", "nf")
    assert {:error, :dupalias} == Shortener.Server.shorten(pid, "https://nephroflow.com", "nf")
  end
end
