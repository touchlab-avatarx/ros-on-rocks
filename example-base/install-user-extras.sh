# Script for installing additional software that has to go into the user directories.
# User directories are not created in the base image, so this script is run after the 
# user directories are created when building the devcontainer image.

echo "🔧 Installing user extras 🔧"

# Install additional software here