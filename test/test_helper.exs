
:erlang.system_flag( :schedulers_online, 1)

ExUnit.start( timeout: 3000)

# Is this idiomatic???
 Path.join( __DIR__, "./support/**/*.exs" )
 |> Path.wildcard
 |> Enum.map( &Code.require_file/1 )
