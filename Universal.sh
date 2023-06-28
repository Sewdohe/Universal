#!/bin/sh
echo -ne '\033c\033]0;Universal\a'
base_path="$(dirname "$(realpath "$0")")"
"$base_path/Universal.x86_64" "$@"
