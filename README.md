# Multi-City Weather ETL and Forecast Accuracy Tracker (Bash)

## Overview

This project implements a simple ETL (Extract, Transform, Load) pipeline in Bash to collect and analyse weather data from the public service `wttr.in`.

The pipeline retrieves weather data for multiple cities, extracts the current observed temperature and the forecasted temperature for the following day at noon, and stores the results in a structured historical dataset. A second script evaluates the accuracy of the forecasts over time.

A detailed write-up of this project is available here:  
[Building an ETL Pipeline in Bash (and What I Learned)](https://andreaparisdata.hashnode.dev/building-an-etl-pipeline-in-bash-and-what-i-learned)

---

## Features

- Multi-city support via `cities.txt`
- Extraction of observed temperature and next-day noon forecast
- Historical data storage in tab-separated (TSV) format
- Forecast error calculation and accuracy classification
- Designed for automation using cron

---

## Project Structure

```text
.
├── cities.txt
├── weather_pipeline.sh
├── forecast_accuracy.sh
├── sample_weather_history.tsv
├── sample_forecast_accuracy.tsv
└── .gitignore
```
---

## How It Works

The project follows a simple ETL workflow:

### Extract
Weather data is retrieved using `curl` from:

`wttr.in/<city>?T`

### Transform
The raw text output is parsed using standard Unix tools:
- `grep` to locate relevant sections
- `cut` to extract columns
- `tr` to clean characters

From this, the script extracts:
- the current observed temperature
- the forecasted temperature for the following day at noon

### Load
The extracted data is appended to a structured tab-separated file:

`weather_history.tsv`

---

## Running the Project
Make the scripts executable:
```
chmod +x weather_pipeline.sh forecast_accuracy.sh
```
Run the ETL pipeline:
```
./weather_pipeline.sh
```
Run the forecast accuracy analysis:
```
./forecast_accuracy.sh
```
---

## Example Output
### Weather History
```
date        city        obs_temp_c   fc_temp_c
2026-04-07  Casablanca  19           14
2026-04-07  London      20           19
2026-04-07  Seoul       4            12
```
### Forecast Accuracy
```
date        city        obs_temp_c   fc_temp_c   error_c   accuracy_label
2026-04-07  Casablanca  19           14          -5        poor
2026-04-07  London      20           19          -1        excellent
2026-04-07  Seoul       4            12           8        poor
```
---

## Scheduling with Cron
The pipeline can be automated to run daily using cron.

Edit your crontab:
```
crontab -e
```
Run the ETL pipeline every day at noon:
```
0 12 * * * /path/to/weather_pipeline.sh
```
Optionally, run the accuracy analysis after data collection:
```
5 12 * * * /path/to/forecast_accuracy.sh
```
---

## Notes
- Designed for Linux environments using GNU core utilities
- Assumes an English locale for parsing date strings from `wttr.in`
- Output files are generated dynamically and excluded via `.gitignore`
---

## Future Improvements
- Add additional weather metrics (wind, precipitation)
- Store data in a database (e.g. SQLite)
- Support multiple forecast sources
- Improve robustness of parsing logic
- Handle non-English locales
---

## Technologies Used
- Bash
- curl
- grep
- cut
- tr
