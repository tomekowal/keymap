defmodule ExKeymap.Keymap do
  alias ExKeymap.KeymapItem
  defstruct [:mappings, :state]

  @opaque t :: [KeymapItem.t()]
  
  def new() do
    %__MODULE__{mappings: [], state: nil}
  end

  def put(%__MODULE__{} = keymap, binding, name, action) do
    %__MODULE__{keymap | mappings: [KeymapItem.new(binding, name, action) | keymap.mappings]}
  end

  def get(%__MODULE__{} = keymap, binding) do
    item = Enum.find(keymap.mappings, fn %KeymapItem{binding: item_binding} -> item_binding == binding end)
    if item do
      item.fun.(keymap.state)
    end
  end
end
