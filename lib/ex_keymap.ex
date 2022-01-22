defmodule ExKeymap do
  @moduledoc """
  A data structure for defining Emacs like key bindings
  inspired by its elisp counterpart
  http://www.gnu.org/software/emacs/manual/html_node/elisp/Keymaps.html

  ## Examples

      iex> keymap = Keymap.new() |> Keymap.put(?a, "action", fn _ -> IO.puts("action!") end)
      iex> capture_io(fn -> Keymap.get(keymap, ?a) end) =~ "action!"
      true
  
  TODO: predicates, state, nesting
  """


end
