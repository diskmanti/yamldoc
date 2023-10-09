#!/bin/bash

print_help() {
  echo "Usage: $0 -p <comment_prefix> -a <annotation_prefix> -f <yaml_file1> [yaml_file2 ...] -o <output_file>"
  exit 0
}

# Check for the correct number of arguments
if [ $# -lt 6 ]; then
  echo "Error: Insufficient arguments."
  print_help
fi

# Initialize variables
comment_prefix=""
annotation_prefix=""
yaml_files=()
output_file=""

while getopts "p:a:f:o:h" opt; do
  case $opt in
    p)
      comment_prefix="$OPTARG"
      ;;
    a)
      annotation_prefix="$OPTARG"
      ;;
    f)
      yaml_files+=("$OPTARG")
      ;;
    o)
      output_file="$OPTARG"
      ;;
    h)
      print_help
      ;;
    \?)
      echo "Invalid option: -$OPTARG"
      exit 1
      ;;
    :)
      echo "Option -$OPTARG requires an argument."
      exit 1
      ;;
  esac
done

# Check if comment_prefix and annotation_prefix are provided
if [ -z "$comment_prefix" ] || [ -z "$annotation_prefix" ]; then
  echo "Error: Comment prefix or annotation prefix not provided."
  print_help
fi

# Check if an output file is provided
if [ -z "$output_file" ]; then
  echo "Error: Output file not provided."
  print_help
fi

# Function to process a YAML file and write comments to the output file
process_comments() {
  local file="$1"
  local comments_table_started=false  # To track if the comments table has started

  while IFS= read -r line; do
    if [[ "$line" == *"$comment_prefix"* ]]; then
      key_value_pair=$(echo "$line" | awk -F"$comment_prefix" '{print $1}')
      comment=$(echo "$line" | awk -F"$comment_prefix" '{print $2}')    
      if ! "$comments_table_started"; then
        # Start the comments table with a custom header and a new line before it
        echo "" >> "$output_file"
        echo "### Comments - $file" >> "$output_file"
        echo "" >> "$output_file"
        echo "| Key-Value Pair | Comment |" >> "$output_file"
        echo "|----------------|---------|" >> "$output_file"
        comments_table_started=true
      fi
      echo "| $key_value_pair | $comment |" >> "$output_file"
    fi
  done < "$file"
}

# Function to process a YAML file and write annotations to the output file using yq
process_annotations() {
  local file="$1"
  
  # Use yq to extract annotations with the specified prefix
  annotations=$(yq eval '.metadata.annotations | with_entries(select(.key | test("^'"$annotation_prefix"'"))) // {}' "$file")

  if [ -n "$annotations" ]; then
    # Start the annotations table with a custom header and a new line before it
    echo "" >> "$output_file"
    echo "### Annotations - $file" >> "$output_file"
    echo "" >> "$output_file"
    echo "| Key-Value Pair | Annotation |" >> "$output_file"
    echo "|----------------|------------|" >> "$output_file"
    
    # Parse and write annotations to the output file
    while read -r line; do
      key=$(echo "$line" | cut -d':' -f1 | tr -d '[:space:]')
      value=$(echo "$line" | cut -d':' -f2- | sed -e 's/^[[:space:]]*//')
      echo "| $key | $value |" >> "$output_file"
    done <<< "$annotations"
  fi
}

# Clear the output file if it already exists
> "$output_file"

# Process each YAML file provided for comments and annotations
for yaml_file in "${yaml_files[@]}"; do
  if [ -f "$yaml_file" ]; then
    process_comments "$yaml_file"
    process_annotations "$yaml_file"
  else
    echo "Error: File not found: $yaml_file"
  fi
done

echo "Markdown tables have been written to $output_file"
