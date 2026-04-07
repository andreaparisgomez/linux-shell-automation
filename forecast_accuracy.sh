#!/bin/bash

input_file="weather_history_test.tsv"
output_file="forecast_accuracy.tsv"

echo -e "date\tcity\tobs_temp_c\tfc_temp_c\terror_c\taccuracy_label" > "$output_file"

prev_city=""
prev_fc=""

tail -n +2 "$input_file" | while IFS=$'\t' read -r date city obs_temp fc_temp; do

  # Clean possible + signs
  obs_temp_clean=$(echo "$obs_temp" | tr -d '+')
  fc_temp_clean=$(echo "$fc_temp" | tr -d '+')

  # If same city as previous row, compare yesterday's forecast with today's observed temperature
  if [ "$city" = "$prev_city" ]; then
    error=$((prev_fc - obs_temp_clean))

    # Calculate absolute error
    if [ "$error" -lt 0 ]; then
      abs_error=$((-1 * error))
    else
      abs_error=$error
    fi

    # Assign accuracy label
    if [ "$abs_error" -le 1 ]; then
      label="excellent"
    elif [ "$abs_error" -le 2 ]; then
      label="good"
    elif [ "$abs_error" -le 3 ]; then
      label="fair"
    else
      label="poor"
    fi

    echo -e "$date\t$city\t$obs_temp_clean\t$prev_fc\t$error\t$label" >> "$output_file"
  fi

  prev_city="$city"
  prev_fc="$fc_temp_clean"

done

echo "Forecast accuracy calculated -> $output_file"
