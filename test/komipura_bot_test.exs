defmodule KomipuraBotTest do
  use ExUnit.Case
  doctest KomipuraBot

  test "greets the world" do
    assert KomipuraBot.hello() == :world
  end
end
