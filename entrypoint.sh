#!/bin/sh -l

export GH_TOKEN=$1
JOB_NAME=$2

# param 3 is minutes, we wait 10seconds between attemnts:
MAX_ATTEMPTS=$(($3 * 6))
ATTEMPTS=0

echo "Installing GitHub CLI..."
curl -sS https://webi.sh/gh | sh
PATH=$PATH:~/.local/bin/

echo "Waiting for $JOB_NAME to complete..."
W_JOB_CONCLUSION=$(gh api -X GET /repos/${GITHUB_REPOSITORY}/actions/runs/${GITHUB_RUN_ID}/jobs -q '.jobs[] | select(.name=="'"$JOB_NAME"'") | .conclusion')
until [ -n "$W_JOB_CONCLUSION" ] || [ $ATTEMPTS -ge $MAX_ATTEMPTS ]; do
  echo "$JOB_NAME is $W_JOB_CONCLUSION ... Attempt $((ATTEMPTS+1))/$MAX_ATTEMPTS"
  sleep 10
  ATTEMPTS=$((ATTEMPTS+1))
  W_JOB_CONCLUSION=$(gh api -X GET /repos/${GITHUB_REPOSITORY}/actions/runs/${GITHUB_RUN_ID}/jobs -q '.jobs[] | select(.name=="'"$JOB_NAME"'") | .conclusion')
done

if [ -z "$W_JOB_CONCLUSION" ]; then
  echo "Job $JOB_NAME did not complete in the given time"
  exit 1
elif [ "$W_JOB_CONCLUSION" != "success" ]; then
  echo "$JOB_NAME failed with conclusion: $W_JOB_CONCLUSION"
  exit 1
fi

echo "$JOB_NAME completed successfully"
