#!/bin/bash
# Common functions for theme scripts

# Read value from TOML file
# Usage: read_toml "file.toml" "section" "key"
# Usage: read_toml "file.toml" "section.subsection" "key"
read_toml() {
    local file="$1"
    local section="$2"
    local key="$3"
    python3 -c "
import tomllib
with open('$file', 'rb') as f:
    data = tomllib.load(f)
keys = '$section'.split('.')
for k in keys:
    data = data[k]
print(data['$key'])
"
}

# Read entire section as key=value pairs
read_toml_section() {
    local file="$1"
    local section="$2"
    python3 -c "
import tomllib
with open('$file', 'rb') as f:
    data = tomllib.load(f)
keys = '$section'.split('.')
for k in keys:
    data = data[k]
for key, val in data.items():
    print(f'{key}={val}')
"
}

# Check if a TOML section exists
toml_section_exists() {
    local file="$1"
    local section="$2"
    python3 -c "
import tomllib
import sys
with open('$file', 'rb') as f:
    data = tomllib.load(f)
keys = '$section'.split('.')
try:
    for k in keys:
        data = data[k]
    sys.exit(0)
except KeyError:
    sys.exit(1)
"
}
