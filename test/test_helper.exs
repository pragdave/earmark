
ExUnit.start()

Path.join( __DIR__, "./support/**/*.exs" )
|> Path.wildcard
|> Enum.map( &Code.require_file/1 )


