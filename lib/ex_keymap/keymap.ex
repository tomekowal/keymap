defmodule ExKeymap.Keymap do
  @behaviour Access
  alias ExKeymap.KeymapItem
  alias ExKeymap.Keymap
  alias ExKeymap.ListHelper

  defstruct [:mappings]

  def new() do
    %__MODULE__{mappings: []}
  end

  def put(%__MODULE__{} = keymap, binding, name, keymap_or_action) do
    put_in(keymap, [binding], name, keymap_or_action)
  end

  # ADR empty list of bindings simply throws function clause error
  def put_in(%__MODULE__{} = keymap, [binding], name, keymap_or_action) do
    keymap
    |> Map.update!(:mappings, fn mappings ->
      mappings
      |> List.keystore(binding, 0, {binding, KeymapItem.new(name, keymap_or_action)})
    end)
  end

  def put_in(%__MODULE__{} = keymap, [current_binding | rest_of_bindings], name, keymap_or_action) do
    keymap
    |> Map.update!(:mappings, fn mappings ->
      mappings
      |> ListHelper.update!(current_binding,
        fn item ->
          item
          |> Map.update!(
            :action_or_keymap,
            fn action_or_keymap ->
              put_in(action_or_keymap, rest_of_bindings, name, keymap_or_action)
            end
          )
        end)
    end)
  end

  @impl Access
  def fetch(%__MODULE__{mappings: mappings}, binding) do
    case List.keyfind(mappings, binding, 0) do
      nil ->
        :error

      {_binding, %KeymapItem{action_or_keymap: action_or_keymap}} ->
        {:ok, action_or_keymap}
    end
  end

  @impl Access
  def get_and_update(%__MODULE__{mappings: mappings} = keymap, binding, fun) do
    {old_value, new_mappings} = get_and_update(mappings, [], binding, fun)
    {old_value, Map.put(keymap, :mappings, new_mappings)}
  end

  defp get_and_update(
         [{binding, %KeymapItem{action_or_keymap: action_or_keymap} = item} | t],
         acc,
         binding,
         fun
       ) do
    case fun.(action_or_keymap) do
      {old_value, new_value} ->
        {old_value, :lists.reverse(acc, [{binding, %KeymapItem{item | action_or_keymap: new_value}} | t])}

      :pop ->
        {action_or_keymap, :lists.reverse(acc, t)}

      other ->
        raise "the given function must return a two-element tuple or :pop, got: #{inspect(other)}"
    end
  end

  defp get_and_update([{_, %KeymapItem{}} = h | t], acc, binding, fun),
    do: get_and_update(t, [h | acc], binding, fun)

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
  def pop(%__MODULE__{mappings: mappings} = keymap, binding) do
    {value, new_mappings} =
      case List.keytake(mappings, binding, 0) do
        {value, updated_mappings} -> {value, updated_mappings}
        nil -> {nil, mappings}
      end
    {value, Map.put(keymap, :mappings, new_mappings)}
  end
end

defimpl Enumerable, for: ExKeymap.Keymap do
  alias ExKeymap.Keymap

  def count(%Keymap{mappings: mappings}) do
    {:ok, length(mappings)}
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
