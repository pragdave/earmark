defmodule Earmark.SysInterface do
  @moduledoc """
  Single Access Point to the impure System Interfcae
  """
  def sys_interface, do: Application.fetch_env!(:earmark, :sys_interface)
end
