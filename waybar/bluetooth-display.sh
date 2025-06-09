#!/bin/bash

# Check if Bluetooth is powered on
if ! bluetoothctl show | grep -q 'Powered: yes'; then
    echo "Off"
    exit 0
fi

# Get connected devices (only actual device lines)
connected_devices=$(bluetoothctl devices Connected | grep "^Device [A-Fa-f0-9:]")

# Check if any devices are connected
if [ -z "$connected_devices" ]; then
    echo "No devices"
    exit 0
fi

# Arrays to store different device types
audio_devices=()
controllers=()
mice=()
other_devices=()

# Process each connected device
while IFS= read -r line; do
    if [ -n "$line" ]; then
        # Extract MAC address and device name
        mac=$(echo "$line" | cut -d ' ' -f2)
        name=$(echo "$line" | cut -d ' ' -f3-)
        
        # Get device info to determine type
        device_info=$(bluetoothctl info "$mac" 2>/dev/null)
        
        # Check device class/type based on UUID or name patterns
        if echo "$device_info" | grep -qi "audio\|headphone\|headset\|speaker\|a2dp\|avrcp" || echo "$name" | grep -qi "ear\|buds\|headphone\|headset"; then
            audio_devices+=("$name")
        elif echo "$name" | grep -qi "controller\|gamepad\|joy\|xbox\|ps\|nintendo\|steam"; then
            controllers+=("$name")
        elif echo "$name" | grep -qi "mouse\|trackball" || echo "$device_info" | grep -qi "mouse"; then
            mice+=("$name")
        else
            other_devices+=("$name")
        fi
    fi
done <<< "$connected_devices"

# Count total connected devices
total_devices=$((${#audio_devices[@]} + ${#controllers[@]} + ${#mice[@]} + ${#other_devices[@]}))

# Display logic based on priority and device count
if [ $total_devices -eq 0 ]; then
    echo "No devices"
elif [ $total_devices -eq 1 ]; then
    # Only one device connected, show whatever it is
    if [ ${#audio_devices[@]} -gt 0 ]; then
        echo "${audio_devices[0]}"
    elif [ ${#controllers[@]} -gt 0 ]; then
        echo "${controllers[0]}"
    elif [ ${#mice[@]} -gt 0 ]; then
        echo "${mice[0]}"
    else
        echo "${other_devices[0]}"
    fi
else
    # Multiple devices connected - prioritize audio > controllers > others > mice
    if [ ${#audio_devices[@]} -gt 0 ]; then
        # Show first audio device
        echo "${audio_devices[0]}"
    elif [ ${#controllers[@]} -gt 0 ]; then
        # Show first controller
        echo "${controllers[0]}"
    elif [ ${#other_devices[@]} -gt 0 ]; then
        # Show first other device
        echo "${other_devices[0]}"
    else
        # Only mice connected
        echo "${mice[0]}"
    fi
fi
