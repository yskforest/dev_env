#!/bin/bash
#
# This script checks the versions of various tools installed in the Docker container.
# It's designed to be run inside the container built from the Dockerfile.

# Exit immediately if a command exits with a non-zero status.
set -e

# Function to print a formatted header
print_header() {
    echo
    echo "--- $1 ---"
}

echo "============================================="
echo "      Development Environment Versions"
echo "============================================="

print_header "Languages & Runtimes"
echo -n "Java:         " && java -version 2>&1 | head -n 1
echo -n "Python:       " && python --version
echo -n "Node.js:      " && node --version
echo -n "Ruby:         " && ruby --version

print_header "Package Managers"
echo -n "npm:          " && npm --version
echo -n "pip:          " && pip --version

print_header "Static Analysis & Linting"
echo -n "PMD:          " && pmd --version
echo -n "cloc:         " && cloc --version
echo -n "textlint:     " && textlint --version
echo -n "reviewdog:    " && reviewdog --version

print_header "Documentation & Diagrams"
echo -n "Doxygen:      " && doxygen --version
echo -n "Graphviz:     " && dot -V 2>&1
echo -n "Asciidoctor:  " && asciidoctor --version

echo
echo "============================================="
