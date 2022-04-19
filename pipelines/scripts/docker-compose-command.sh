#!/bin/bash
# Run an command against Docker images from a Docker-Compose file
set -e

# Help                                                     #
############################################################

help()
{
   # Display Help
   echo
   echo "Usage: ./docker-compose-command.sh [OPTIONS] -c 'dive @image'"
   echo
   echo "Run a command against images from a Docker-Compose file."
   echo "@image is replaced with the name of the docker image."
   echo 
   echo "Mandatory Options:"
   echo "  -c                   Command to run against each image."
   echo 
   echo "Options:"
   echo "  -f                   Path for docker-compose file."
   echo "  -p                   Profile filter."
   echo "  -i                   Image filter - the image name must contain this string."
   echo "  -e                   Image exclude filter - the image name must not contain this string."
   echo "  -t                   Image tag - defaults to 'latest'."
   echo "  -h                   Print this Help."
   echo
}

############################################################
############################################################
# Main program                                             #
############################################################
############################################################

# Set variables

filePath="docker-compose.yml"
profile=""
imageFilter=""
imageExcludeFilter="_____"
tag="latest"
registry=""
command=""

############################################################
# Process the input options.                               #
############################################################
# Get the options
while getopts ":hi:p:t:f:e:c:r:" option; do
   case $option in
      h) # display Help
         help
         exit;;
      f) # set docker-compose file
         filePath=$OPTARG;;
      t) # set the image tag
         tag=$OPTARG;;
      p) # set the profile filter
         echo "Filtering images for profile: $OPTARG"
         profile=$OPTARG;;
      i) # set the image filter
         echo "Filtering images containing: $OPTARG"
         imageFilter=$OPTARG;;
      e) # set the image exclude filter
         echo "Filtering images not containing: $OPTARG"
         imageExcludeFilter=$OPTARG;;
      r) # set docker registry
         registry="$OPTARG/";;
      c) # set command to execute
         command=$OPTARG;;
      \?) # Invalid option
         echo "Error: Invalid option"
         exit;;
   esac
done

############################################################
# Validate arguments                                       #
############################################################
if [[ "$command" == "" ]]; then
  echo "-c COMMAND is a mandatory option"
  help
  exit 2
fi

############################################################
# Tag images                                               #
############################################################
echo "Running command against images from: ${filePath}"

SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )

$SCRIPT_DIR/docker-compose-extract.sh -f "${filePath}" -p "${profile}" -i "${imageFilter}" -e "${imageExcludeFilter}" | while read -r line ; do
   image="${line//$\{TAG:-dev\}/$tag}"
   image="${image//$\{DOCKER_REGISTRY\}/$registry}"
   imageCommand="${command/@image/"$image"}"
   echo $imageCommand
   eval "$imageCommand"
done