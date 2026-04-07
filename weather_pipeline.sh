#!/bin/bash

cities_file="cities.txt"
output_file="weather_history.tsv"

# Create output file with header if it doesn't exist
if [ ! -f "$output_file" ]; then
  echo -e "date\tcity\tobs_temp_c\tfc_temp_c" > "$output_file"
fi

# macOS-compatible tomorrow label for wttr.in table, e.g. "Wed 08 Apr"
tomorrow_label=$(date -v+1d "+%a %d %b")
today_date=$(date "+%Y-%m-%d")

while IFS= read -r city; do
  [ -z "$city" ] && continue

  weather_data=$(curl -s "wttr.in/${city}?T")

  # Current observed temperature: first occurrence of a Celsius value near the top
  obs_temp=$(echo "$weather_data" \
    | grep -m 1 '°C' \
    | grep -Eo -- '[+-]?[0-9]+' \
    | head -1)

  # Find tomorrow's temperature row in the forecast table
  temp_row=$(echo "$weather_data" \
    | awk -v day="$tomorrow_label" '
        index($0, day) {
          for (i = 0; i < 4; i++) getline
          print
          exit
        }')

  # Extract the Noon column (2nd forecast column)
  noon_cell=$(echo "$temp_row" | awk -F '│' '{print $3}')

  # If value looks like +14(13) °C, take the value in parentheses (13).
  # Otherwise take the last numeric value in the cell.
  fc_temp=$(echo "$noon_cell" | sed -nE 's/.*\(([+-]?[0-9]+)\).*/\1/p')

  if [ -z "$fc_temp" ]; then
    fc_temp=$(echo "$noon_cell" \
      | grep -Eo -- '[+-]?[0-9]+' \
      | tail -1)
  fi

  echo -e "$today_date\t$city\t$obs_temp\t$fc_temp" >> "$output_file"
  echo "Recorded $city | Obs: ${obs_temp}°C | Forecast tomorrow noon: ${fc_temp}°C"

done < "$cities_file"
