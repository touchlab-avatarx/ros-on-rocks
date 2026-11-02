#!/bin/bash

set -e

# Parse command line arguments
TARGET="$1"  # Optional target parameter

# Validate target if provided
if [[ -n "$TARGET" ]] && [[ ! "$TARGET" =~ ^(stable|latest|[0-9]+\.[0-9]+\.[0-9]+(-[^[:space:]]+)?)$ ]]; then
    echo "Usage: $0 [stable|latest|VERSION]" >&2
    exit 1
fi

DOWNLOAD_BASE_URL="https://downloads.claude.ai/claude-code-releases"
DOWNLOAD_DIR="/opt/claude/downloads"

# Check for required dependencies
DOWNLOADER=""
if command -v curl >/dev/null 2>&1; then
    DOWNLOADER="curl"
elif command -v wget >/dev/null 2>&1; then
    DOWNLOADER="wget"
else
    echo "Either curl or wget is required but neither is installed" >&2
    exit 1
fi

# Check if jq is available (optional)
HAS_JQ=false
if command -v jq >/dev/null 2>&1; then
    HAS_JQ=true
fi

HAS_ZSTD=false
if command -v zstd >/dev/null 2>&1; then
    HAS_ZSTD=true
fi

# Download function that works with both curl and wget
download_file() {
    local url="$1"
    local output="$2"
    
    if [ "$DOWNLOADER" = "curl" ]; then
        if [ -n "$output" ]; then
            curl -fsSL -o "$output" "$url"
        else
            curl -fsSL "$url"
        fi
    elif [ "$DOWNLOADER" = "wget" ]; then
        if [ -n "$output" ]; then
            wget -q -O "$output" "$url"
        else
            wget -q -O - "$url"
        fi
    else
        return 1
    fi
}

# Simple JSON parser for extracting checksum when jq is not available
get_checksum_from_manifest() {
    local json="$1"
    local platform="$2"
    
    # Normalize JSON to single line and extract checksum
    json=$(echo "$json" | tr -d '\n\r\t' | sed 's/ \+/ /g')
    
    # Extract checksum for platform using bash regex. [^{}] keeps the match
    # inside the platform's own object (manifest.zst.json nests a darwin bundle).
    if [[ $json =~ \"$platform\"[[:space:]]*:[[:space:]]*[{][^{}]*\"checksum\"[[:space:]]*:[[:space:]]*\"([a-f0-9]{64})\" ]]; then
        echo "${BASH_REMATCH[1]}"
        return 0
    fi
    
    return 1
}

get_size_from_manifest() {
    local json="$1"
    local platform="$2"
    json=$(echo "$json" | tr -d '\n\r\t' | sed 's/ \+/ /g')
    if [[ $json =~ \"$platform\"[[:space:]]*:[[:space:]]*[{][^{}]*\"size\"[[:space:]]*:[[:space:]]*([0-9]+) ]]; then
        echo "${BASH_REMATCH[1]}"
        return 0
    fi
    return 1
}

# Detect platform
case "$(uname -s)" in
    Darwin) os="darwin" ;;
    Linux) os="linux" ;;
    MINGW*|MSYS*|CYGWIN*) echo "Windows is not supported by this script. See https://code.claude.com/docs for installation options." >&2; exit 1 ;;
    *) echo "Unsupported operating system: $(uname -s). See https://code.claude.com/docs for supported platforms." >&2; exit 1 ;;
esac

case "$(uname -m)" in
    x86_64|amd64) arch="x64" ;;
    arm64|aarch64) arch="arm64" ;;
    *) echo "Unsupported architecture: $(uname -m)" >&2; exit 1 ;;
esac

# Detect Rosetta 2 on macOS: if the shell is running as x64 under Rosetta on an ARM Mac,
# download the native arm64 binary instead of the x64 one
if [ "$os" = "darwin" ] && [ "$arch" = "x64" ]; then
    if [ "$(sysctl -n sysctl.proc_translated 2>/dev/null)" = "1" ]; then
        arch="arm64"
    fi
fi

# Check for musl on Linux and adjust platform accordingly
if [ "$os" = "linux" ]; then
    if [ -f /lib/libc.musl-x86_64.so.1 ] || [ -f /lib/libc.musl-aarch64.so.1 ] || ldd /bin/ls 2>&1 | grep -q musl; then
        platform="linux-${arch}-musl"
    else
        platform="linux-${arch}"
    fi
else
    platform="${os}-${arch}"
fi
mkdir -p "$DOWNLOAD_DIR"

# Resolve the version to package: the wrapper below installs exactly this binary
case "${TARGET:-latest}" in
    stable|latest) version=$(download_file "$DOWNLOAD_BASE_URL/${TARGET:-latest}") ;;
    *) version="$TARGET" ;;
esac

# Reject non-version content (e.g. an HTML error page) before it reaches the manifest URL
if [[ ! "$version" =~ ^[0-9]+\.[0-9]+\.[0-9]+ ]]; then
    echo "Failed to get a valid version from downloads.claude.ai (got unexpected content)." >&2
    echo "This can happen if the download service is unreachable or not available in your region - see https://www.anthropic.com/supported-countries" >&2
    exit 1
fi

# Download manifest and extract checksum
manifest_json=$(download_file "$DOWNLOAD_BASE_URL/$version/manifest.json")

# Use jq if available, otherwise fall back to pure bash parsing
if [ "$HAS_JQ" = true ]; then
    checksum=$(echo "$manifest_json" | jq -r ".platforms[\"$platform\"].checksum // empty")
    size=$(echo "$manifest_json" | jq -r ".platforms[\"$platform\"].size // empty")
else
    checksum=$(get_checksum_from_manifest "$manifest_json" "$platform" || true)
    size=$(get_size_from_manifest "$manifest_json" "$platform" || true)
fi

# Validate checksum format (SHA256 = 64 hex characters)
if [ -z "$checksum" ] || [[ ! "$checksum" =~ ^[a-f0-9]{64}$ ]]; then
    echo "Platform $platform not found in manifest" >&2
    exit 1
fi

checksum_matches() {
    local actual
    if [ "$os" = "darwin" ]; then
        actual=$(shasum -a 256 "$1" | cut -d' ' -f1)
    else
        actual=$(sha256sum "$1" | cut -d' ' -f1)
    fi
    [ "$actual" = "$2" ]
}

zst_checksum=""
if [ "$HAS_ZSTD" = true ] && [[ "$size" =~ ^[1-9][0-9]*$ ]]; then
    zst_manifest_json=$(download_file "$DOWNLOAD_BASE_URL/$version/manifest.zst.json" 2>/dev/null || true)
    if [ "$HAS_JQ" = true ]; then
        zst_checksum=$(echo "$zst_manifest_json" | jq -r ".platforms[\"$platform\"].checksum // empty" 2>/dev/null || true)
    else
        zst_checksum=$(get_checksum_from_manifest "$zst_manifest_json" "$platform" || true)
    fi
fi

binary_path="$DOWNLOAD_DIR/claude-$version-$platform"
verified=false
if [[ "$zst_checksum" =~ ^[a-f0-9]{64}$ ]]; then
    if download_file "$DOWNLOAD_BASE_URL/$version/$platform/claude.zst" "$binary_path.zst" \
        && checksum_matches "$binary_path.zst" "$zst_checksum"; then
        zstd -d -q -c "$binary_path.zst" 2>/dev/null | head -c "$size" > "$binary_path" || true
        if checksum_matches "$binary_path" "$checksum"; then
            verified=true
        fi
    fi
    rm -f "$binary_path.zst"
fi
if [ "$verified" = false ]; then
    if ! download_file "$DOWNLOAD_BASE_URL/$version/$platform/claude" "$binary_path"; then
        echo "Download failed" >&2
        rm -f "$binary_path"
        exit 1
    fi
    if ! checksum_matches "$binary_path" "$checksum"; then
        echo "Checksum verification failed" >&2
        rm -f "$binary_path"
        exit 1
    fi
fi

chmod 755 "$binary_path"

# Set up a wrapper script that installs the downloaded binary for the current user.
# It does the file operations itself because "claude install" needs network access.
cat > /usr/bin/install-claude <<EOF
#!/bin/sh
set -e
echo "Setting up Claude Code..."
mkdir -p "\$HOME/.local/bin" "\$HOME/.local/share/claude/versions"
cp -f "$binary_path" "\$HOME/.local/share/claude/versions/$version"
ln -sf "\$HOME/.local/share/claude/versions/$version" "\$HOME/.local/bin/claude"
[ -e "\$HOME/.claude.json" ] || (umask 077 && echo '{"installMethod":"native"}' > "\$HOME/.claude.json")
echo ""
echo "✅ Installation complete!"
echo ""
EOF
chmod 755 /usr/bin/install-claude
