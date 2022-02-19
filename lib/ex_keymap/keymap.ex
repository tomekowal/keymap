defmodule ExKeymap.Keymap do
  @behaviour Access
  alias ExKeymap.KeymapItem
  alias ExKeymap.Keymap
  defstruct [:mappings]

  def new() do
    %__MODULE__{mappings: []}
  end

  # TODO allow putting it at concrete place
  # TODO warn if already exists
  def put(%__MODULE__{} = keymap, binding, name, keymap_or_action) do
    keymap
    |> update_mappings(fn mappings ->
      [KeymapItem.new(binding, name, keymap_or_action) | mappings]
    end)
  end

  defp update_mappings(%__MODULE__{mappings: mappings} = keymap, fun) do
    %__MODULE__{keymap | mappings: fun.(mappings)}
  end

  def get(%__MODULE__{mappings: mappings}, binding) do
    item =
      Enum.find(mappings, fn %KeymapItem{binding: item_binding} ->
        item_binding == binding
      end)

    case item.action_or_keymap do
      %Keymap{} = keymap -> keymap
      # TODO should I call the action here?
      action when is_function(action, 0) -> action.()
    end
  end

  # TODO what about empty list in bindings
  def put_in(%__MODULE__{} = keymap, [binding], name, keymap_or_action),
    do: put(keymap, binding, name, keymap_or_action)

  # TODO how to make this more readable?
  def put_in(%__MODULE__{} = keymap, [first_binding | rest_of_bindings], name, keymap_or_action) do
    %__MODULE__{
      keymap
      | mappings:
          Enum.map(
            keymap.mappings,
            fn
              %KeymapItem{binding: ^first_binding} = item ->
                %KeymapItem{
                  item
                  | action_or_keymap:
                      put_in(item.action_or_keymap, rest_of_bindings, name, keymap_or_action)
                }

              item ->
                item
            end
          )
    }
  end

  @impl Access
  def fetch(%__MODULE__{} = keymap, binding) do
    finder_fn = fn %KeymapItem{binding: item_binding} -> item_binding == binding end
    case Enum.find(keymap.mappings, finder_fn) do
      nil -> :error
      %KeymapItem{action_or_keymap: action_or_keymap} ->
        case action_or_keymap do
          %Keymap{} = keymap -> {:ok, keymap}
          function when is_function(function, 0) -> {:ok, function.()}
        end
    end
  end

  @impl Access
  def get_and_update(%__MODULE__{} = keymap, binding, fun) do
    {old_value, new_mappings} = get_and_update(keymap.mappings, [], binding, fun)
    {old_value, %__MODULE__{keymap | mappings: new_mappings}}
  end

  defp get_and_update([%KeymapItem{binding: binding, action_or_keymap: action_or_keymap} = item | t], acc, binding, fun) do
    case fun.(action_or_keymap) do
      {old_value, new_value} ->
        {old_value, :lists.reverse(acc, [%KeymapItem{item | action_or_keymap: new_value} | t])}

      :pop ->
        {action_or_keymap, :lists.reverse(acc, t)}

      other ->
        raise "the given function must return a two-element tuple or :pop, got: #{inspect(other)}"
    end
  end

  defp get_and_update([%KeymapItem{} = h | t], acc, binding, fun), do: get_and_update(t, [h | acc], binding, fun)

  defp get_and_update([], acc, binding, fun) do
    case fun.(nil) do
      {_old_value, _new_value} ->
        raise "binding #{inspect(binding)} not found"

      :pop ->
        {nil, :lists.reverse(acc)}

      other ->
        raise "the given function must return a two-element tuple or :pop, got: #{inspect(other)}"
    end
  end

  @impl Access
  def pop(_data, _key) do
    # TODO implement
    raise "NOT FULLY IMPLEMENTED!"
  end
end

defimpl Enumerable, for: ExKeymap.Keymap do
  alias ExKeymap.Keymap

  def count(%Keymap{mappings: mappings}) do
    {:ok, Enum.count(mappings)}
  end

  @spec member?(%ExKeymap.Keymap{}, any) :: {:error, Enumerable.ExKeymap.Keymap}
  def member?(_, _) do
    {:error, __MODULE__}
  end

  def reduce(%Keymap{mappings: mappings}, acc, fun) do
    Enumerable.List.reduce(mappings, acc, fun)
  end

  def slice(_) do
    {:error, __MODULE__}
  end
end
