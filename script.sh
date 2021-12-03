#!/bin/bash

capture_lead_time_for_changes() {
  LAST_COMMIT_HASH=$(echo $(git log --format=%H -n 1))
  LAST_COMMIT_DATETIME=$(echo $(git log --format=%at -n 1))
  LAST_COMMIT_MESSAGE=$(echo $(git log --format=%B -n 1))

  REGEX='^(feat|fix|docs|refactor|test|build|ci|chore|revert|)\:\s+(\w{2,4}-[0-9]+*)\s+.*'

  [[ "$LAST_COMMIT_MESSAGE" =~ $REGEX ]]

  ISSUE_ID="${BASH_REMATCH[2]}"

  COMMIT_HISTORY_FILTER=$(git log --format=%H --reverse --all --grep=${ISSUE_ID})
  COMMIT_HISTORY=$(echo ${COMMIT_HISTORY_FILTER} | sed 's|\s|,|g')
  TOTAL_COMMITS_LENGTH=$(echo ${COMMIT_HISTORY_FILTER} | awk '{n=split($0, array, " ")} END{print n }')
  FIRST_COMMIT_HASH=$(echo ${COMMIT_HISTORY_FILTER} | awk '{print $1}')
  FIRST_COMMIT_DATETIME=$(git log ${FIRST_COMMIT_HASH} --format=%at -n 1)

  JSON_RESULT=$(jq -n \
    --arg last_commit_hash "${LAST_COMMIT_HASH}" \
    --arg last_commit_datetime "${LAST_COMMIT_DATETIME}" \
    --arg first_commit_hash "${FIRST_COMMIT_HASH}" \
    --arg first_commit_datetime "${FIRST_COMMIT_DATETIME}" \
    --arg commit_history "${COMMIT_HISTORY}" \
    --arg commit_history_length "${TOTAL_COMMITS_LENGTH}" \
    '$ARGS.named'
  )

  echo $JSON_RESULT
}


capture_lead_time_for_changes
