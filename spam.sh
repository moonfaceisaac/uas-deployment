#!/bin/bash

URL="http://localhost:3000/todo/get"
DURATION=120  # 2 minutes in seconds
REQUESTS_PER_BATCH=15

echo "🔥 Spamming $URL for 2 minutes"
echo "Batch size: $REQUESTS_PER_BATCH requests"
echo "Started at: $(date)"

# Store start time
start_time=$SECONDS
end_time=$((start_time + DURATION))

# Main loop
while [ $SECONDS -lt $end_time ]; do
  # Send requests in parallel
  for ((i=1; i<=REQUESTS_PER_BATCH; i++)); do
    curl -s "$URL" > /dev/null &
  done
  
  # Wait for current batch
  wait
  
  # Calculate progress
  elapsed=$((SECONDS - start_time))
  remaining=$((end_time - SECONDS))
  progress=$((elapsed * 100 / DURATION))
  
  # Show progress bar
  printf "\r["
  for ((i=0; i<progress/2; i++)); do printf "#"; done
  for ((i=progress/2; i<50; i++)); do printf " "; done
  printf "] %3d%% | Time: %3ds | Remaining: %3ds" $progress $elapsed $remaining
done

echo -e "\n✅ Done! Load test completed at: $(date)"