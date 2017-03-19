defmodule Model do
  @derive [Poison.Encoder]

  defmodule LogState do
    defstruct [:unix_datetime, :state_file]
  end

  defmodule StateFile do
    defstruct [:basedir, :paths]
  end

  defmodule Paths do
    defstruct [:hash, :new, :old, :size]
  end
end