defmodule ConfigFile do
  @derive [Poison.Encoder]
  defstruct [:undo, :delete_size_st, :rename_pattern]
end