#!/bin/bash

# Check for hotel availability on a given date
# Usage: ./check-availability.sh --date YYYY-MM-DD --hostel-id ID --hostel-name NAME --guests-count COUNT --guests-param PARAM

set -o pipefail

# Parse named arguments
while [[ $# -gt 0 ]]; do
  case $1 in
    --date)
      DATE="$2"
      shift 2
      ;;
    --hostel-id)
      HOSTEL_ID="$2"
      shift 2
      ;;
    --hostel-name)
      HOSTEL_NAME="$2"
      shift 2
      ;;
    --guests-count)
      GUESTS_COUNT="$2"
      shift 2
      ;;
    --guests-param)
      GUESTS_PARAM="$2"
      shift 2
      ;;
    *)
      echo "Unknown option: $1"
      exit 1
      ;;
  esac
done

if [[ -z "$DATE" || -z "$HOSTEL_ID" || -z "$HOSTEL_NAME" || -z "$GUESTS_COUNT" || -z "$GUESTS_PARAM" ]]; then
  echo "Usage: $0 --date YYYY-MM-DD --hostel-id ID --hostel-name NAME --guests-count COUNT --guests-param PARAM"
  exit 1
fi

# Validate date format (YYYY-MM-DD)
if [[ ! "$DATE" =~ ^[0-9]{4}-[0-9]{2}-[0-9]{2}$ ]]; then
  echo "Error: Date must be in YYYY-MM-DD format (got: $DATE)"
  exit 1
fi

# Validate date is a real date
if ! date -d "$DATE" &>/dev/null; then
  echo "Error: Invalid date: $DATE"
  exit 1
fi

# Parse date components
YEAR="${DATE:0:4}"
MONTH="${DATE:5:2}"
DAY="${DATE:8:2}"

EXPECTED_DATE="${DATE}"
DEPARTURE_DATE=$(date -d "${DATE} + 1 day" +'%Y-%m-%d')

# Query the API for availability
URL="https://api.widgets.bookingsuedtirol.com/v6/properties/${HOSTEL_ID}/availabilities?from=${YEAR}-${MONTH}-01&guests=%5B%5B${GUESTS_PARAM}%5D%5D&sourceId=98&to=${YEAR}-${MONTH}-30"
DATES=$(curl -s "$URL")
echo "Response: $DATES"

echo "$DATES" | jq -e -r ".[] | select(.date == \"${EXPECTED_DATE}\") | .departures[] | select(.rule == \"departure_possible\" and .departure == \"${DEPARTURE_DATE}\") | .departure"

# Append an output if the command succeeds
if [[ $? -eq 0 ]]; then
  echo "The spot is available for $EXPECTED_DATE."
  echo "available=true" >> "$GITHUB_OUTPUT"

  MONTH_NAME=$(date -d "${EXPECTED_DATE}" +'%B')
  echo "message=A spot is available for ${MONTH_NAME} ${DAY} for ${GUESTS_COUNT} guest(s) at: ${HOSTEL_NAME} (id: ${HOSTEL_ID})." >> "$GITHUB_OUTPUT"
else
  echo "No spot available for $EXPECTED_DATE."
  echo "available=false" >> "$GITHUB_OUTPUT"
fi
