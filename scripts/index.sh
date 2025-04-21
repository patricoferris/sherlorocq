#! bash

if [ -z "$1" ]; then
  echo 'missing source directory'
  exit 1
fi

if [ -z "$2" ]; then
  echo 'missing target directory'
  exit 1
fi

dune build index/index.exe

find "$1" -name '*.v*' \
  | sort -R \
  | dune exec -- index/index.exe --prefix="$1" "$2"
