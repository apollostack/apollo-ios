#!/usr/bin/env bash

# Exit on all errors, undeclared variables and pipefailures.
set -euo pipefail

# Advertisement!
echo "Have you tried our new Swift Package Manager wrapper around codegen? It's now out of beta and ready to go! See docs at https://www.apollographql.com/docs/ios/swift-scripting/. This Bash script will be deprecated soon, so give it a try today!"

# Get the path to the script directory
SCRIPT_DIR="$(dirname "$0")"

# Get the SHASUM of the tarball
ZIP_FILE="${SCRIPT_DIR}/apollo.tar.gz"
ZIP_FILE_DOWNLOAD_URL="https://install.apollographql.com/legacy-cli/darwin/2.33.1"
SHASUM_FILE="${SCRIPT_DIR}/apollo/.shasum"
APOLLO_DIR="${SCRIPT_DIR}"/apollo
IS_RETRY="false"
SHASUM=""

# Helper functions
download_apollo_cli_if_needed() {
  echo "Checking if CLI needs to be downloaded..."
  if [ -f "${ZIP_FILE}" ]; then
    echo "Zip file already downloaded!"
  else
    download_cli
  fi
}

download_cli() {
  echo "Downloading zip file with the CLI..."
  curl --silent --retry 3 --fail --show-error -L "${ZIP_FILE_DOWNLOAD_URL}" -o "${ZIP_FILE}"
}

force_cli_download() {
  rm -r "${ZIP_FILE}"
  remove_existing_apollo
  download_cli
  IS_RETRY="true"
  validate_codegen_and_extract_if_needed
}

update_shasum() {
  SHASUM="$(/usr/bin/shasum -a 256 "${ZIP_FILE}" | /usr/bin/awk '{ print $1 }')"
}

remove_existing_apollo() {
  if [[ -f "${APOLLO_DIR}" ]]; then
    rm -r "${APOLLO_DIR}"
  fi
}

extract_cli() {
  tar xzf "${SCRIPT_DIR}"/apollo.tar.gz -C "${SCRIPT_DIR}"

  echo "${SHASUM}" | tee "${SHASUM_FILE}"
}

validate_codegen_and_extract_if_needed() {
  # Make sure the SHASUM matches the release for this version
  EXPECTED_SHASUM="6db58afa176a11f240ddcd40b03e6a2b89ab0536b822223c44f9e1f95aac0459"
  update_shasum

  if [[ ${SHASUM} = ${EXPECTED_SHASUM}* ]]; then
    echo "Correct version of the CLI tarball is downloaded locally, checking if it's already been extracted..."
  else
    if [[ "${IS_RETRY}" == "true" ]]; then
      #This was a retry, and the SHASUM still doesn't match.
      echo "Error: The SHASUM of this zip file does not match the official released version from Apollo! This may present security issues. Terminating code generation." >&2
      exit 1
    else
      # This was the first attempt, the version may have changed.
      echo "Incorrect version of the CLI tarball is downloaded locally, redownloading the zip from the server."
      force_cli_download
    fi
  fi

  # Check if the SHASUM file has already been written for this version
  if [ -f "${SHASUM_FILE}" ]; then
    # The file exists, let's see if it's the same SHASUM
    FILE_CONTENTS="$(cat "${SHASUM_FILE}")"
    if [[ ${FILE_CONTENTS} = ${EXPECTED_SHASUM}* ]]; then
      echo "Current verson of CLI is already extracted!"
    else
      echo "Extracting updated version of the Apollo CLI. This may take a minute..."
      remove_existing_apollo
      extract_cli
    fi
  else
    # The file doesn't exist, unzip the CLI
    echo "Extracting the Apollo CLI. This may take a minute..."
    extract_cli
  fi
}

# Download the current version of the CLI if it doesn't exist
download_apollo_cli_if_needed

# Make sure we're using an up-to-date and valid version of the Apollo CLI
validate_codegen_and_extract_if_needed

# Add the binary directory to the beginning of PATH so included binary verson of node is used.
PATH="${SCRIPT_DIR}/apollo/bin:${PATH}"

# Use the bundled executable of the Apollo CLI to generate code
APOLLO_CLI="${SCRIPT_DIR}/apollo/bin/run"

# Print version
echo "Apollo CLI Information: $("${APOLLO_CLI}" --version)"

# Print commands before executing them (useful for troubleshooting)
set -x
"$APOLLO_CLI" "$@"
