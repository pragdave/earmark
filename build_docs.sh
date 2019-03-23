#!/usr/bin/env bash

function ex_doc {
  local ex_doc=$1
  mix escript.build

  $ex_doc Earmark $(./earmark --version) _build/dev/lib/earmark/ebin -m Earmark -u "https://github.com/pragdave/earmark"
}

function check {
  local escript="$EX_DOC_ESCRIPT"
  if test -d "${escript}"
  then
    escript="${escript}/ex_doc"
  fi
  if test -x "${escript}"
  then
    ex_doc ${escript}
  else
    echo "Error ex_doc not found, please set en_var EX_DOC_ESCRIPT" >&2
  fi
}

check
