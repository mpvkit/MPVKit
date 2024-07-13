#!/bin/bash

arch_info=$(uname -m)
if [[ "$arch_info" == "i386" ||  "$arch_info" == "i686" ||"$arch_info" == "x86_64" ]]; then
    arch="x86_64"
else
    arch="arm64"
fi

bin="./dist/libmpv/macos/thin/$(arch)/bin/mpv"
if [ ! -f "$bin" ]; then
  echo "mpv binary not found on path: $bin, please build first."
  exit 1
fi

$bin "$@"