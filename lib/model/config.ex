defmodule Model do
  @derive [Poison.Encoder]
  
  defmodule Config do
    defstruct [
      :undo_changes,
      :rename_patterns,
      :extensions_keep,
      :extensions_delete]
  end

  defmodule Patterns do
    defstruct [:regex, :replace, :input, :output]
  end
end