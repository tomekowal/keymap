defmodule ExKeymap.KeymapItem do
  defstruct [:binding, :name, :action_or_keymap, :help]

  def new(binding, name, action_or_keymap, help \\ nil) do
    %__MODULE__{
      binding: binding,
      name: name,
      action_or_keymap: action_or_keymap,
      help: help
    }
  end
end
