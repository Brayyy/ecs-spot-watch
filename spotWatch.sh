#!/bin/bash

# If EC2 is not spot, sleep forever or exit immediately
if [ "$(curl -s http://169.254.169.254/latest/meta-data/instance-life-cycle)" == "normal" ]; then
  if [ "$EXIT_IF_NOT_SPOT" == "true" ]; then
    echo "$(date +%s) - instance-life-cycle: normal, exiting"
    exit 0
  fi
  echo "$(date +%s) - instance-life-cycle: normal, sleeping forever"

  # Lock up the loop
  while :; do sleep 3600; done
fi

# Read ECS data for later
ECS_CLUSTER=$(curl -s http://localhost:51678/v1/metadata | jq -r .Cluster)
CONTAINER_INSTANCE=$(curl -s http://localhost:51678/v1/metadata | jq -r .ContainerInstanceArn)

# Every 5 seconds, check termination time
while sleep 5; do
  if [ -z $(curl -Isf http://169.254.169.254/latest/meta-data/spot/termination-time)]; then
    if [ "$SHOW_OK" == "true" ]; then
      echo "$(date +%s) - OK"
    fi
  else
    echo "$(date +%s) - Instance marked for termination"

    # Try to remove instance from cluster. Retry until successful
    while :; do
      /usr/local/bin/aws ecs update-container-instances-state \
        --cluster $ECS_CLUSTER \
        --container-instances $CONTAINER_INSTANCE \
        --status DRAINING && break
      sleep 5
    done

    # Lock up the loop
    while :; do sleep 3600; done
  fi
done
