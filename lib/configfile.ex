defmodule ConfigFile do
  @derive [Poison.Encoder]
  defstruct [
    :undo_changes,
    :rename_patterns,
    :extensions_keep,
    :extensions_delete]
end

defmodule Patterns do
  @derive [Poison.Encoder]
  defstruct [:regex, :replace, :input, :output]
end