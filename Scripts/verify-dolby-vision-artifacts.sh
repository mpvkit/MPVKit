#!/usr/bin/env bash
set -euo pipefail

usage() {
  cat <<'USAGE'
Usage: Scripts/verify-dolby-vision-artifacts.sh [ARTIFACT_ROOT]

Verifies that a standard (non-GPL) MPVKit artifact set is safe to publish
with native Dolby Vision support:
  - FFmpeg config headers report CONFIG_GPL 0 and CONFIG_NONFREE 0
  - FFmpeg binaries do not contain an obvious nonfree license/config string
  - Libplacebo was built with PL_HAVE_LIBDOVI 1
  - Libplacebo references dovi symbols and Libdovi exports them

ARTIFACT_ROOT defaults to the current directory. Point it at a directory that
contains resolved or unpacked xcframeworks, for example .build/artifacts or
dist/release/xcframework.
USAGE
}

if [[ "${1:-}" == "-h" || "${1:-}" == "--help" ]]; then
  usage
  exit 0
fi

root="${1:-.}"
if [[ ! -d "$root" ]]; then
  echo "error: artifact root does not exist: $root" >&2
  exit 2
fi

require_tool() {
  if ! command -v "$1" >/dev/null 2>&1; then
    echo "error: required tool not found: $1" >&2
    exit 2
  fi
}

require_tool find
require_tool strings
require_tool awk

failures=0
fail() {
  echo "FAIL: $*" >&2
  failures=$((failures + 1))
}

pass() {
  echo "PASS: $*"
}

find_first_file() {
  local name="$1"
  find "$root" -type f -name "$name" -print -quit
}

find_matching_files() {
  local pattern="$1"
  find "$root" -type f -name "$pattern" -print
}

find_standard_matching_files() {
  local pattern="$1"
  find "$root" -type f -name "$pattern" ! -path '*-GPL*' -print
}

check_config_flag() {
  local flag="$1"
  local expected="$2"
  local found=0

  while IFS= read -r config; do
    found=1
    if awk -v flag="$flag" -v expected="$expected" '
      $1 == "#define" && $2 == flag { found = 1; if ($3 != expected) exit 1 }
      END { if (!found) exit 2 }
    ' "$config"; then
      :
    else
      fail "$config does not define $flag as $expected"
    fi
  done < <(find_standard_matching_files config.h | grep -E '/include/libav(codec|format|util)/config\.h$' || true)

  if [[ "$found" -eq 0 ]]; then
    fail "no FFmpeg config.h files found under $root"
  else
    pass "FFmpeg config headers were checked for $flag=$expected"
  fi
}

check_no_nonfree_strings() {
  local found=0
  while IFS= read -r lib; do
    found=1
    if strings "$lib" | grep -Eiq 'License:.*nonfree|configuration:.*--enable-nonfree|--enable-nonfree'; then
      fail "$lib contains an apparent nonfree FFmpeg license/configuration string"
    fi
  done < <(find "$root" -type f \( -name 'Libav*.a' -o -name 'libav*.a' -o -name 'Libav*' -o -name 'libav*' \) ! -path '*-GPL*' -print)

  if [[ "$found" -eq 0 ]]; then
    fail "no FFmpeg library files found under $root"
  else
    pass "FFmpeg library strings were checked for nonfree markers"
  fi
}

check_libplacebo_dovi_header() {
  local header
  header="$(find "$root" -type f \( -name 'config.h' -o -name 'config_internal.h' \) -print0 | xargs -0 grep -l 'PL_HAVE_LIBDOVI' 2>/dev/null | head -n 1 || true)"

  if [[ -z "$header" ]]; then
    fail "no Libplacebo config header containing PL_HAVE_LIBDOVI found under $root"
    return
  fi

  if grep -Eq '#define[[:space:]]+PL_HAVE_LIBDOVI[[:space:]]+1' "$header"; then
    pass "Libplacebo reports PL_HAVE_LIBDOVI 1 in $header"
  else
    fail "$header does not report PL_HAVE_LIBDOVI 1"
  fi
}

symbol_output() {
  local file="$1"
  if command -v nm >/dev/null 2>&1; then
    nm -gU "$file" 2>/dev/null || nm -g "$file" 2>/dev/null || strings "$file"
  else
    strings "$file"
  fi
}

check_dovi_symbols() {
  local placebo_libs=()
  local dovi_libs=()
  local lib

  while IFS= read -r lib; do placebo_libs+=("$lib"); done < <(find "$root" -type f \( -name 'Libplacebo.a' -o -name 'libplacebo.a' -o -name 'Libplacebo' -o -name 'libplacebo' \) -print)
  while IFS= read -r lib; do dovi_libs+=("$lib"); done < <(find "$root" -type f \( -name 'Libdovi.a' -o -name 'libdovi.a' -o -name 'Libdovi' -o -name 'libdovi' \) -print)

  if [[ "${#placebo_libs[@]}" -eq 0 ]]; then
    fail "no Libplacebo library found under $root"
  else
    local referenced=0
    for lib in "${placebo_libs[@]}"; do
      if symbol_output "$lib" | grep -Eq '_?dovi_'; then
        referenced=1
        break
      fi
    done
    if [[ "$referenced" -eq 1 ]]; then
      pass "Libplacebo references dovi symbols"
    else
      fail "Libplacebo does not reference dovi symbols"
    fi
  fi

  if [[ "${#dovi_libs[@]}" -eq 0 ]]; then
    fail "no Libdovi library found under $root"
  else
    local exported=0
    for lib in "${dovi_libs[@]}"; do
      if symbol_output "$lib" | grep -Eq '(^|[[:space:]])_?dovi_'; then
        exported=1
        break
      fi
    done
    if [[ "$exported" -eq 1 ]]; then
      pass "Libdovi exports dovi symbols"
    else
      fail "Libdovi does not export dovi symbols"
    fi
  fi
}

check_config_flag CONFIG_GPL 0
check_config_flag CONFIG_NONFREE 0
check_no_nonfree_strings
check_libplacebo_dovi_header
check_dovi_symbols

if [[ "$failures" -ne 0 ]]; then
  echo "Dolby Vision artifact verification failed with $failures issue(s)." >&2
  exit 1
fi

echo "Dolby Vision artifact verification passed."
