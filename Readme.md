Az Devops Build Agent for building IoT Modules in Arm32v7 devices

## Command to Build the Image
 docker build -t "ImageName" .

## Command to run the container
 docker run -e AZP_URL=<AZ DEVOPS URL> -e AZP_TOKEN=<PAT> -e AZP_AGENT_NAME=<AGENTNAME> -v  /var/run/docker.sock:/var/run/docker.sock 
"ImageName"
