defmodule ExKeymapTest do
  use ExUnit.Case
  doctest ExKeymap
  alias ExKeymap.Keymap
  alias ExKeymap.KeymapItem

  test "greets the world" do
    ki = KeymapItem.new("button")
  end
end
