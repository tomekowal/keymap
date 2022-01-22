defmodule ExKeymap.KeymapItem do
  defstruct [:binding, :name, :fun, :help, :predicate]

  @type state :: any()
  @type binding :: 32..127

  @type t :: %__MODULE__{
    binding: binding(),
    name: String.t(),
    fun: (state() -> any()),
    help: String.t() | nil,
    predicate: (state() -> boolean())
  }

  @spec new(binding(), String.t(), (state() -> any()), String.t() | nil, (state() -> boolean())) :: t()
  def new(binding, name, fun, help \\ nil, predicate \\ fn _ -> true end) do
    %__MODULE__{
      binding: binding,
      name: name,
      fun: fun,
      help: help,
      predicate: predicate
    }
  end
end
