# yamldoc

## Overview

This Bash script allows you to extract comments and annotations from one or more YAML files and generate Markdown tables for documentation purposes. It is particularly useful when working with Kubernetes manifests or any other YAML-based configuration files that contain comments and annotations.

## Features

- Extracts comments and annotations from YAML files.
- Supports multiple input YAML files.
- Generates Markdown tables for comments and annotations.
- Accepts command-line arguments in any order.

## Prerequisites

- Bash (Unix shell)
- [yq](https://mikefarah.gitbook.io/yq/) - A YAML processor for extracting annotations.

## Usage

```bash
./yaml_doc.sh -p <comment_prefix> -a <annotation_prefix> -f <yaml_file1> [yaml_file2 ...] -o <output_file>
```

- -p <comment_prefix>: Specify the comment prefix to extract comments from YAML files.
- -a <annotation_prefix>: Specify the annotation prefix to extract annotations from YAML files.
- -f <yaml_file1> [yaml_file2 ...]: Specify one or more YAML files to process.
- -o <output_file>: Specify the output file where the Markdown tables will be saved.
- -h: Display the help message.

*Note*: You can provide the command-line arguments in any order.

## Example

```bash
./yamldoc.sh -p "# docs" -a "diskmanti.me" -f example.yaml another.yaml -o output.md
```
