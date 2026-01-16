#!/bin/bash

URL="http://localhost:3030"
DURATION=120
REQUEST_COUNT=0

echo "🌐 Simulating realistic frontend traffic"
echo "Target: $URL"
echo "Duration: ${DURATION}s"
echo ""

# Browser-like headers
HEADERS=(
    "User-Agent: Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36"
    "Accept: text/html,application/xhtml+xml,application/xml"
    "Accept-Language: en-US,en;q=0.9"
    "Accept-Encoding: gzip, deflate"
    "Connection: keep-alive"
    "Cache-Control: max-age=0"
)

# Random delay function
random_delay() {
    echo $(awk -v min=0.05 -v max=0.3 'BEGIN{srand(); print min+rand()*(max-min)}')
}

send_request() {
    # Randomly choose headers
    RAND_HEADER=${HEADERS[$RANDOM % ${#HEADERS[@]}]}
    
    curl -s -H "$RAND_HEADER" \
         -H "Accept: text/html" \
         "$URL" > /dev/null &
}

START=$(date +%s)
END=$((START + DURATION))

while [ $(date +%s) -lt $END ]; do
    # Variable load: 5-25 concurrent requests
    CONCURRENT=$((5 + RANDOM % 20))
    
    for ((i=0; i<CONCURRENT; i++)); do
        send_request
        REQUEST_COUNT=$((REQUEST_COUNT + 1))
    done
    
    wait
    
    # Random sleep between batches (0.1-0.5s)
    sleep $(random_delay)
    
    # Progress
    CURRENT=$(date +%s)
    ELAPSED=$((CURRENT - START))
    REMAINING=$((END - CURRENT))
    
    if [ $((ELAPSED % 10)) -eq 0 ]; then
        echo "[$(date)] Sent: $REQUEST_COUNT requests | Active: ~$CONCURRENT | Left: ${REMAINING}s"
    fi
done

echo ""
echo "📊 Test Results:"
echo "Total requests: $REQUEST_COUNT"
echo "Average RPS: $((REQUEST_COUNT / DURATION))"
echo "Test completed at: $(date)"