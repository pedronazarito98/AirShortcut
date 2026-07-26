#!/usr/bin/env bash
set -euo pipefail

if [[ $# -ne 1 ]]; then
  echo "usage: $0 <hardware-report.md>" >&2
  exit 64
fi

report_path=$1

if [[ ! -f "$report_path" ]]; then
  echo "hardware report not found: $report_path" >&2
  exit 66
fi

sensitive_pattern='serial|tcc([[:space:]_-]*(dump|database|db))?|user[[:space:]_-]*name|raw[[:space:]_-]*(frame|touch)|/users/|/home/|[a-z]:\\users\\'
if grep -Eiq "$sensitive_pattern" "$report_path"; then
  echo "hardware report contains a prohibited sensitive marker" >&2
  exit 1
fi

awk -F '|' '
  function trim(value) {
    gsub(/^[[:space:]]+|[[:space:]]+$/, "", value)
    return value
  }

  BEGIN {
    expected_header = "OS|Device class|Capture mode|Gesture/scenario|Expected|Observed|Status|Notes"
    header_found = 0
    data_rows = 0
  }

  /^\|/ {
    if (NF != 10) {
      print "invalid report row: expected exactly eight columns at line " NR > "/dev/stderr"
      exit 1
    }

    row = ""
    for (column = 2; column <= 9; column++) {
      value[column] = trim($column)
      row = row (column == 2 ? "" : "|") value[column]
    }

    if (!header_found) {
      if (row == expected_header) {
        header_found = 1
      }
      next
    }

    if (value[2] ~ /^-+$/) {
      next
    }

    for (column = 2; column <= 9; column++) {
      if (value[column] == "") {
        print "invalid report row: empty required column at line " NR > "/dev/stderr"
        exit 1
      }
    }

    if (value[3] !~ /^(internal|magic-trackpad|other|unknown)$/) {
      print "invalid device class at line " NR > "/dev/stderr"
      exit 1
    }
    if (value[4] !~ /^(advanced-private|public-fallback|unavailable)$/) {
      print "invalid capture mode at line " NR > "/dev/stderr"
      exit 1
    }
    if (value[8] !~ /^(PASS|FAIL|NOT-RUN)$/) {
      print "invalid status at line " NR > "/dev/stderr"
      exit 1
    }

    data_rows++
  }

  END {
    if (!header_found) {
      print "required hardware report header not found" > "/dev/stderr"
      exit 1
    }
    if (data_rows == 0) {
      print "hardware report contains no evidence rows" > "/dev/stderr"
      exit 1
    }
  }
' "$report_path"

echo "hardware report is structurally valid and contains no prohibited markers"
