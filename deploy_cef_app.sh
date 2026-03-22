#!/bin/bash
set -euo pipefail

# Script: Deploy and build the minimal CEF application on Debian 11 (Bullseye) ARM64
# Target: RK3588 Rockchip bare-metal
# Purpose: Automate setup steps implied by the prior tutorial content (build prerequisites,
#          obtain CEF binaries, configure/build the app, and provide run guidance).
# Note: This script is designed to run from the user's home directory.

# -----------------------------
# Configuration Variables
# -----------------------------
SCRIPT_NAME="deploy_cef_app.sh"
SOURCE_DIR_DEFAULT="$HOME/renhiyama-cefapp-sample"
SOURCE_DIR="${SOURCE_DIR:-$SOURCE_DIR_DEFAULT}"
CEF_VERSION_DEFAULT="130.1.16+g5a7e5ed+chromium-130.0.6723.117"
CEF_VERSION="${CEF_VERSION:-$CEF_VERSION_DEFAULT}"
CEF_BINARY_URL_DEFAULT="https://cef-builds.spotifycdn.com/cef_binary_${CEF_VERSION}_linux64_minimal.tar.bz2"
CEF_BINARY_URL="${CEF_BINARY_URL:-}"
BUILD_DIR_REL="src/build"
BUILD_TYPE="Release"

# Temporary directory for downloads
TEMP_DIR=""

# -----------------------------
# Helper Functions
# -----------------------------
cleanup_temp() {
  echo "[INFO] Cleaning up temporary files..."
  if [ -n "${TEMP_DIR}" ] && [ -d "${TEMP_DIR}" ]; then
    rm -rf "${TEMP_DIR}"
    echo "[INFO] Removed temporary directory: ${TEMP_DIR}"
  fi
}
trap cleanup_temp EXIT SIGINT SIGTERM

error_exit() {
  echo "[ERROR] $1" >&2
  exit 1
}

run_checked() {
  local description="$1"
  shift
  echo "[INFO] ${description}"
  if ! "$@"; then
    error_exit "Failed to ${description}."
  fi
}

ensure_command() {
  local tool_name="$1"
  local package_name="$2"
  if ! command -v "$tool_name" >/dev/null 2>&1; then
    echo "[INFO] Tool '${tool_name}' not found. Installing '${package_name}'..."
    if ! sudo apt install -y "$package_name"; then
      error_exit "Failed to install '${package_name}'."
    fi
    echo "[INFO] '${package_name}' installed successfully."
  else
    echo "[INFO] Tool '${tool_name}' is already installed."
  fi
}

ensure_package() {
  local package_name="$1"
  if ! dpkg -s "$package_name" >/dev/null 2>&1; then
    echo "[INFO] Package '${package_name}' not installed. Installing..."
    if ! sudo apt install -y "$package_name"; then
      error_exit "Failed to install '${package_name}'."
    fi
  else
    echo "[INFO] Package '${package_name}' is already installed."
  fi
}

check_source_dir() {
  if [ ! -d "$SOURCE_DIR" ]; then
    echo "[ERROR] Source directory not found at: ${SOURCE_DIR}" >&2
    echo "[ERROR] Set SOURCE_DIR to the path containing the CEF sample app sources." >&2
    exit 1
  fi
  if [ ! -d "${SOURCE_DIR}/src" ]; then
    error_exit "Expected 'src' directory not found under ${SOURCE_DIR}."
  fi
}

verify_architecture() {
  local arch
  arch="$(uname -m)"
  echo "[INFO] Detected architecture: ${arch}"
  if [ "${arch}" = "aarch64" ] || [ "${arch}" = "arm64" ]; then
    echo "[INFO] ARM64 detected. Ensure the CEF bundle matches ARM64."
    if [ -z "${CEF_BINARY_URL}" ]; then
      echo "[ERROR] CEF_BINARY_URL is empty on ARM64." >&2
      echo "[ERROR] Provide an ARM64-compatible CEF tarball URL." >&2
      exit 1
    fi
    if [ "${CEF_BINARY_URL}" = "${CEF_BINARY_URL_DEFAULT}" ]; then
      echo "[ERROR] The default CEF URL targets linux64 (x86_64)." >&2
      echo "[ERROR] Set CEF_BINARY_URL to an ARM64-compatible CEF minimal build archive." >&2
      exit 1
    fi
  else
    if [ -z "${CEF_BINARY_URL}" ]; then
      CEF_BINARY_URL="${CEF_BINARY_URL_DEFAULT}"
    fi
  fi
}

prepare_build_dependencies() {
  run_checked "update package lists" sudo apt update

  ensure_command "curl" "curl"
  ensure_command "wget" "wget"
  ensure_command "git" "git"
  ensure_command "cmake" "cmake"
  ensure_command "make" "build-essential"
  ensure_command "pkg-config" "pkg-config"
  ensure_command "tar" "tar"

  # X11 development dependencies needed by CEF on Linux
  ensure_package "libx11-dev"
  ensure_package "libxext-dev"
  ensure_package "libxrender-dev"
  ensure_package "libxrandr-dev"
  ensure_package "libxcomposite-dev"
  ensure_package "libxcursor-dev"
  ensure_package "libxi-dev"
  ensure_package "libxtst-dev"
  ensure_package "libxss-dev"
  ensure_package "libxdamage-dev"
  ensure_package "libxfixes-dev"
}

fetch_cef_binary() {
  if [ -d "${SOURCE_DIR}/cef_binary" ]; then
    echo "[INFO] Existing cef_binary directory found at ${SOURCE_DIR}/cef_binary."
    return 0
  fi

  if [ -z "${CEF_BINARY_URL}" ]; then
    if [ -f "${SOURCE_DIR}/download_prebuilt_cef.sh" ]; then
      echo "[INFO] Running download_prebuilt_cef.sh for CEF version ${CEF_VERSION}..."
      if ! (cd "${SOURCE_DIR}" && CEF_VERSION="${CEF_VERSION}" ./download_prebuilt_cef.sh); then
        error_exit "Failed to download CEF binaries via download_prebuilt_cef.sh."
      fi
      return 0
    fi
    error_exit "CEF_BINARY_URL is empty and download_prebuilt_cef.sh is missing."
  fi

  TEMP_DIR="$(mktemp -d)"
  local archive_path="${TEMP_DIR}/cef_binary.tar.bz2"

  echo "[INFO] Downloading CEF binary from: ${CEF_BINARY_URL}"
  if ! curl -Lfo "${archive_path}" "${CEF_BINARY_URL}"; then
    error_exit "Failed to download CEF binary archive."
  fi

  echo "[INFO] Extracting CEF binary archive..."
  if ! tar -xvf "${archive_path}" -C "${TEMP_DIR}"; then
    error_exit "Failed to extract CEF binary archive."
  fi

  local extracted_dir
  extracted_dir="$(find "${TEMP_DIR}" -maxdepth 1 -type d -name 'cef_binary_*' | head -n 1)"
  if [ -z "${extracted_dir}" ]; then
    error_exit "Failed to locate extracted CEF directory."
  fi

  echo "[INFO] Copying CEF binaries into source tree..."

  if ! mv "${extracted_dir}" "${SOURCE_DIR}/cef_binary"; then
    error_exit "Failed to move CEF binaries into source tree."
  fi
}

build_cef_app() {
  local build_dir="${SOURCE_DIR}/${BUILD_DIR_REL}"
  if [ ! -d "${build_dir}" ]; then
    if ! mkdir -p "${build_dir}"; then
      error_exit "Failed to create build directory ${build_dir}."
    fi
  fi

  echo "[INFO] Configuring CEF app with CMake..."
  if ! (cd "${build_dir}" && cmake ..); then
    error_exit "CMake configuration failed."
  fi

  echo "[INFO] Building CEF app..."
  if ! (cd "${build_dir}" && make -j"$(nproc)"); then
    error_exit "Build failed."
  fi
}

print_run_instructions() {
  local exe_path="${SOURCE_DIR}/${BUILD_DIR_REL}/${BUILD_TYPE}/cefapp"
  echo "[INFO] Build completed."
  echo "[INFO] To run the application, execute:"
  echo "  ${exe_path}"
  echo "[INFO] Example with URL override:"
  echo "  ${exe_path} --url=chrome://gpu"
}

# -----------------------------
# Main Script Execution
# -----------------------------
echo "[INFO] Starting ${SCRIPT_NAME}..."

echo "[INFO] Validating source directory..."
check_source_dir

verify_architecture

prepare_build_dependencies

fetch_cef_binary

build_cef_app

print_run_instructions

echo "[INFO] ${SCRIPT_NAME} completed successfully."
