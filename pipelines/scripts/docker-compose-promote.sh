#!/bin/bash
# Tag images from a Docker-Compose file
set -e

# Help                                                     #
############################################################

help()
{
   # Display Help
   echo
   echo "Usage: ./docker-compose-promote.sh [OPTIONS] -r REGISTRY -u PROMOTE_REGISTRY"
   echo
   echo "Tag images from a Docker-Compose file for promoting to a new environment"
   echo 
   echo "Mandatory Options:"
   echo "  -r                   Docker registry to promote from."
   echo "  -u                   Upper Docker registry to promote to."
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
promoteToRegistry=""

############################################################
# Process the input options.                               #
############################################################
# Get the options
while getopts ":hi:p:t:f:e:r:u:" option; do
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
         registry=$OPTARG;;
      u) # set promote to docker registry
         promoteToRegistry=$OPTARG;;
      \?) # Invalid option
         echo "Error: Invalid option"
         exit;;
   esac
done

############################################################
# Validate arguments                                       #
############################################################
if [[ "$registry" == "" ]]; then
  echo "-r REGISTRY is a mandatory option"
  help
  exit 2
elif [[ "$promoteToRegistry" == "" ]]; then
  echo "-u PROMOTE_REGISTRY is a mandatory option"
  help
  exit 2
fi

############################################################
# Tag images                                               #
############################################################
echo "Promoting images from $registry to $promoteToRegistry"
echo "Tagging images from: ${filePath}"
 
SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )

$SCRIPT_DIR/docker-compose-extract.sh -f "${filePath}" -p "${profile}" -i "${imageFilter}" -e "${imageExcludeFilter}" | while read -r line ; do
    line="${line//$\{TAG:-dev\}/$tag}"
    image="${line//$\{DOCKER_REGISTRY\}/$registry/}"
    prometedImage="${line//$\{DOCKER_REGISTRY\}/$promoteToRegistry/}"
    tagCommand="docker tag $image $prometedImage"
    echo "$tagCommand"
    eval "$tagCommand"
done