defmodule ExKeymap do
  @moduledoc """
  A data structure for defining Emacs like key bindings
  inspired by its elisp counterpart
  http://www.gnu.org/software/emacs/manual/html_node/elisp/Keymaps.html

  ## Examples

      iex> keymap = Keymap.new() |> Keymap.put(?a, "action a name", fn -> "result a" end)
      iex> keymap[?a]
      "result a"

      iex> inner = Keymap.new() |> Keymap.put(?b, "action b name", fn -> "result b" end)
      iex> keymap = Keymap.new() |> Keymap.put(?a, "submenu a", inner)
      iex> keymap[?a][?b]
      "result b"

      iex> inner = Keymap.new() |> Keymap.put(?b, "action b name", fn -> "result b" end)
      iex> keymap = Keymap.new() |> Keymap.put(?a, "submenu a", inner)
      iex> keymap = Keymap.put_in(keymap, [?a, ?c], "action c", fn -> "action c" end)
      iex> keymap[?a][?c]
      "action c"

      iex> keymap = Keymap.new() |> Keymap.put(?a, "action a", fn -> "action a" end)
      iex> for %{binding: binding, name: name} <- keymap, do: {binding, name}
      [{?a, "action a"}]
  """
end
