#!/bin/bash

mod="$HOME/.local/nu_base/mod.nu"
app="$HOME/.usr/local/bin/nu"

if [ -f "$app" ] && [ -f "$mod" ]; then
    exec "$app" -e "source '$mod'"
else
    exec bash
fi
