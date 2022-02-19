defmodule Keymap.KeymapItem do
  defstruct [:binding, :name, :action_or_keymap, :help]

  def new(name, action_or_keymap, help \\ nil)

  def new(name, action, help) when is_function(action, 0) do
    %__MODULE__{
      name: name,
      action_or_keymap: action,
      help: help
    }
  end

  def new(name, %Keymap{} = keymap, help) do
    %__MODULE__{
      name: name,
      action_or_keymap: keymap,
      help: help
    }
  end
end
