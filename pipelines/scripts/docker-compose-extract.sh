#!/bin/bash
# Extract values from a Docker-Compose file
set -e

# Help                                                     #
############################################################

help()
{
   # Display Help
   echo
   echo "Usage: ./docker-compose-extract.sh [OPTIONS]"
   echo
   echo "Extract values from a Docker-Compose file"
   echo 
   echo "Options:"
   echo "  -f                   Path for docker-compose file."
   echo "  -i                   Image filter - the image name must contain this string."
   echo "  -e                   Image exclude filter - the image name must not contain this string."
   echo "  -p                   Profile."
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
imageFilter=""
imageExcludeFilter="_____"
profile=""

############################################################
# Process the input options.                               #
############################################################
# Get the options
while getopts ":hi:p:f:e:" option; do
   case $option in
      h) # display Help
         help
         exit;;
      f) # set docker-compose file
         filePath=$OPTARG;;
      p) # set the profile
         profile=$OPTARG;;
      i) # set the image filter
         imageFilter=$OPTARG;;
      e) # set the image exclude filter
         imageExcludeFilter=$OPTARG;;
      \?) # Invalid option
         echo "Error: Invalid option"
         exit;;
   esac
done

############################################################
# Extract values                                           #
############################################################
images=$(cat $filePath | grep image:)
arrImages=($(echo "${images//image: /}"))

profiles=$(cat $filePath | grep profiles: | sed 's/ //g')
arrProfiles=($(echo "${profiles//profiles:/}"))

extract()
{
   image="$1"
   profiles="$2"
   if [[ "$image" == *"${imageFilter}"* ]] && [[ "$image" != *"${imageExcludeFilter}"* ]]; then
      if [[ "$profile" == "" ]] || [[ "$profiles" == *"\"$profile\""* ]]; then          
         echo $image
      fi
   fi
}

for i in "${!arrImages[@]}"; do
   extract ${arrImages[$i]} ${arrProfiles[$i]}
done