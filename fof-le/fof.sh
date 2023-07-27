#!/bin/sh
echo -ne '\033c\033]0;fof\a'
base_path="$(dirname "$(realpath "$0")")"
"$base_path/fof.x86_64" "$@"
