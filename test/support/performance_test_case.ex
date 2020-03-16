defmodule Support.PerformanceTestCase do

  defmacro __using__(_options) do
    quote do
      use ExUnit.Case, async: false 
      import Support.Performance

      @moduletag :performance
    end
  end
  
end

# SPDX-License-Identifier: Apache-2.0
