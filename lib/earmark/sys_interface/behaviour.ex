defmodule Earmark.SysInterface.Behavior do
  @callback readlines(IO.io_device()) :: list(binary())
end
