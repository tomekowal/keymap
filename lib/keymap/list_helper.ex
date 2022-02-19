defmodule Keymap.ListHelper do
  def update!(list, key, fun) when is_list(list) and is_function(fun, 1) do
    update!(list, key, fun, list)
  end

  defp update!([{key, value} | list], key, fun, _original) do
    [{key, fun.(value)} | list]
  end

  defp update!([{_, _} = pair | list], key, fun, original) do
    [pair | update!(list, key, fun, original)]
  end

  defp update!([], key, _fun, original) do
    raise KeyError, key: key, term: original
  end
end
