defmodule BasicTest do
  use ExUnit.Case

  setup do
    {:ok, pid: Shortener.Basic.start_link}
  end

  test "shortening a url", %{pid: pid} do
    send(pid, {:shorten, self(), "nf", "https://nephroflow.com"})
    assert_receive(:ok)

    send(pid, {:url, self(), "nf"})
    assert_receive({:ok, "https://nephroflow.com"})
  end

  test "finding a url that does not exist", %{pid: pid} do
    send(pid, {:url, self(), "derp"})
    assert_receive(:error)
  end
end
