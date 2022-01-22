defmodule ExKeymap.Keymap do
  defstruct [:mappings]

  alias ExKeymap.KeymapItem

  @type key :: 32..127 #aplha numeric range
  @type t :: %__MODULE__{
    mappings: [{key(), t() | KeymapItem.t()}]
  }
end
