# :erlang.system_flag( :schedulers_online, 1)

ExUnit.configure(exclude: [:wip, :later, :dev, :performance], timeout: 10_000_000)
ExUnit.start()

# SPDX-License-Identifier: Apache-2.0
