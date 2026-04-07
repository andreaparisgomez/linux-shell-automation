#!/bin/bash

cities_file="cities.txt"
output_file="weather_history.tsv"

# Create output file with header if it doesn't exist
if [ ! -f "$output_file" ]; then
  echo -e "date\tcity\tobs_temp_c\tfc_temp_c" > "$output_file"
fi

# Linux/GNU date format matching wttr.in table, e.g. "Wed 08 Apr"
tomorrow_label=$(date -d "tomorrow" "+%a %d %b")
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
    | grep -A 5 "$tomorrow_label" \
    | tail -1)

  # Extract the Noon column (2nd forecast column)
  noon_cell=$(echo "$temp_row" | cut -d '│' -f3)

  # If value looks like +14(13) °C, take the value in parentheses (13)
  fc_temp=$(echo "$noon_cell" \
    | grep -Eo '[0-9]+\)' \
    | grep -Eo '[0-9]+')

  # Fallback: if no parentheses are present, take the last number in the cell
  if [ -z "$fc_temp" ]; then
    fc_temp=$(echo "$noon_cell" | grep -Eo '[0-9]+' | tail -1)
  fi

  echo -e "$today_date\t$city\t$obs_temp\t$fc_temp" >> "$output_file"
  echo "Recorded $city | Obs: ${obs_temp}°C | Forecast tomorrow noon: ${fc_temp}°C"

done < "$cities_file"
