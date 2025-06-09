#!/bin/bash

echo "=== DEBUG: Raw bluetoothctl devices Connected output ==="
bluetoothctl devices Connected

echo ""
echo "=== DEBUG: Processing each line ==="
bluetoothctl devices Connected | while IFS= read -r line; do
    if [ -n "$line" ]; then
        echo "Raw line: '$line'"
        mac=$(echo "$line" | cut -d ' ' -f2)
        echo "MAC: '$mac'"
        name_method1=$(echo "$line" | cut -d ' ' -f3-)
        echo "Name method 1 (cut): '$name_method1'"
        name_method2=$(echo "$line" | sed 's/^Device [A-Fa-f0-9:]* //')
        echo "Name method 2 (sed): '$name_method2'"
        
        if [[ -n "$mac" ]]; then
            info_output=$(bluetoothctl info "$mac" 2>/dev/null)
            echo "Info command worked: $([ -n "$info_output" ] && echo "yes" || echo "no")"
            if [[ -n "$info_output" ]]; then
                info_name=$(echo "$info_output" | grep "Name:" | sed 's/.*Name: //')
                echo "Name from info: '$info_name'"
            fi
        fi
        echo "---"
    fi
done
