#!/bin/bash

# This script creates a standard Java Maven project directory structure.

# Define the root directory name for the backend
ROOT_DIR="backend"

# Print message indicating script start
echo "Creating Java backend structure in '$ROOT_DIR'..."

# Create the root backend directory
# The -p flag ensures that mkdir doesn't throw an error if the directory already exists
mkdir -p "$ROOT_DIR"

# Check if the root directory was created successfully
if [ ! -d "$ROOT_DIR" ]; then
  echo "Error: Failed to create root directory '$ROOT_DIR'."
  exit 1 # Exit the script with an error code
fi

# Navigate into the root directory
cd "$ROOT_DIR" || exit # Use || exit to stop if cd fails

# Create the nested source directory structure
# The -p flag is crucial here as it creates all parent directories (src, main, java, com, example, demo) if they don't exist.
echo "Creating source directories..."
mkdir -p "src/main/java/com/example/demo/"

# Check if the deepest directory was created successfully
if [ ! -d "src/main/java/com/example/demo/" ]; then
  echo "Error: Failed to create nested source directories."
  cd .. # Go back to the original directory before exiting
  exit 1
fi

# Create the empty Java files within the nested structure
echo "Creating Java files..."
touch "src/main/java/com/example/demo/DemoApplication.java"
touch "src/main/java/com/example/demo/HelloController.java"

# Create the pom.xml file in the root of the backend directory
echo "Creating pom.xml..."
touch "pom.xml"

# Navigate back to the original directory (optional, good practice)
cd ..

# Print success message
echo "Java backend structure created successfully:"
# Use 'tree' command if available, otherwise 'ls' for basic listing
if command -v tree &> /dev/null; then
  tree "$ROOT_DIR"
else
  echo "---"
  ls -R "$ROOT_DIR" # List contents recursively as a fallback
  echo "--- (Install 'tree' for a better view: brew install tree)"
fi

exit 0 # Exit the script successfully
