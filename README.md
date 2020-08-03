# ECS Spot Watch
_A lightweight Docker container to drain EC2 Spot instances from your ECS cluster_

On start up, this Docker container will check if the EC2 it is running on is a spot instance or not. If not, it will remain running, but will sleep forever. If it is a spot instance, it will try to read some config from ECS about itself, then check for EC2 termination every 5 seconds, forever. If termination is detected, it will attempt to notify ECS that the EC2 instance should be put into a "DRAINING" state.

The container is based off [Amazon's official amazon/aws-cli container](https://hub.docker.com/r/amazon/aws-cli). The only dependency is jq, and the script is written in bash, keeping the memory footprint extremely low (~2MB in my testing).

Environment variables for additional configuration:

| Key | Default | Description |
| - | - | - |
| `EXIT_IF_NOT_SPOT` | `false` |  If set `true`, script will exit if the instance-life-cycle is set to normal, and not spot. This is usually not preferred, as your container scheduler may consider this to be an error, and try to relaunch. |
| `SHOW_OK` | `false` | If set `true`, script will print "OK" for every 5 second loop. |
