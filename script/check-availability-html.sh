#!/bin/bash

# Check for hotel availability by searching HTML response for availability phrase
# Usage: ./check-availability-html.sh --url URL --available-phrase PHRASE --hostel-name NAME [--form-data key=value ...]

set -o pipefail

# Initialize form data array
FORM_DATA_ARGS=()

# Parse named arguments
while [[ $# -gt 0 ]]; do
  case $1 in
    --url)
      URL="$2"
      shift 2
      ;;
    --available-phrase)
      AVAILABLE_PHRASE="$2"
      shift 2
      ;;
    --hostel-name)
      HOSTEL_NAME="$2"
      shift 2
      ;;
    --form-data)
      FORM_DATA_ARGS+=("-d" "$2")
      shift 2
      ;;
    *)
      echo "Unknown option: $1"
      exit 1
      ;;
  esac
done

if [[ -z "$URL" || -z "$AVAILABLE_PHRASE" || -z "$HOSTEL_NAME" ]]; then
  echo "Usage: $0 --url URL --available-phrase PHRASE --hostel-name NAME [--form-data key=value ...]"
  exit 1
fi

# Fetch the HTML content
if [[ ${#FORM_DATA_ARGS[@]} -gt 0 ]]; then
  RESPONSE=$(curl -s -X POST "${FORM_DATA_ARGS[@]}" "$URL")
else
  RESPONSE=$(curl -s "$URL")
fi

echo "Response length: ${#RESPONSE} characters"
#echo "--------"
#echo "$RESPONSE"
#echo "--------"

# Check if the availability phrase is present
if echo "$RESPONSE" | grep -qi "$AVAILABLE_PHRASE"; then
  echo "Availability phrase found: '$AVAILABLE_PHRASE'"
  echo "A spot is available at $HOSTEL_NAME!"
  echo "available=true" >> "$GITHUB_OUTPUT"
  echo "message=A spot is available at ${HOSTEL_NAME}. Check at ${URL}" >> "$GITHUB_OUTPUT"
else
  echo "Availability phrase NOT found: '$AVAILABLE_PHRASE'"
  echo "No spot available at $HOSTEL_NAME."
  echo "available=false" >> "$GITHUB_OUTPUT"
fi


# curl 'https://rifugiolagazuoi.com/EN/prenotazione1.php' \
#   --compressed \
#   -X POST \
#   -H 'User-Agent: Mozilla/5.0 (Macintosh; Intel Mac OS X 10.15; rv:147.0) Gecko/20100101 Firefox/147.0' \
#   -H 'Accept: text/html,application/xhtml+xml,application/xml;q=0.9,*/*;q=0.8' \
#   -H 'Accept-Language: en-US,en;q=0.9' \
#   -H 'Accept-Encoding: gzip, deflate, br, zstd' \
#   -H 'Referer: https://rifugiolagazuoi.com/EN/disponibilita.php?prm=8&chm=1' \
#   -H 'Content-Type: application/x-www-form-urlencoded' \
#   -H 'Origin: https://rifugiolagazuoi.com' \
#   -H 'Connection: keep-alive' \
#   -H 'Upgrade-Insecure-Requests: 1' \
#   -H 'Sec-Fetch-Dest: document' \
#   -H 'Sec-Fetch-Mode: navigate' \
#   -H 'Sec-Fetch-Site: same-origin' \
#   -H 'Sec-Fetch-User: ?1' \
#   -H 'Priority: u=0, i' \
#   --data-raw 'arrivo=14-09-2026&partenza=15-09-2026&persone=1'

# ./script/check-availability-html.sh \
#   --url "https://rifugiolagazuoi.com/EN/prenotazione1.php" \
#   --unavailable-phrase "Sorry, we do not have any room available for these dates" \
#   --hostel-name "Rifugio Lagazuoi" \
#   --form-data "arrivo=14-09-2026" \
#   --form-data "partenza=15-09-2026" \
#   --form-data "persone=1"
  