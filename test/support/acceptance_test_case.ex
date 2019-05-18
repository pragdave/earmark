defmodule Support.AcceptanceTestCase do

  defmacro __using__(_options) do
    quote do
      use ExUnit.Case
      alias Earmark.Options
      import Support.Helpers, only: [as_html: 1, as_html: 2]
    end
  end
  
end


# SPDX-License-Identifier: Apache-2.0
