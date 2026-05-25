#!/usr/bin/env bash
set -euo pipefail

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
package_url="https://github.com/daveboster/SwiftSankeyDiagram.git"
dependency_mode="public"
user_clang_module_cache_path="${CLANG_MODULE_CACHE_PATH:-}"

if [[ "${1:-}" == "--local-package" ]]; then
    dependency_mode="local"
elif [[ "${1:-}" != "" ]]; then
    echo "usage: $0 [--local-package]" >&2
    exit 1
fi

examples=(
    "CashflowSankeyExample"
    "CashflowCollapsedIncomeExample"
)

validate_manifest() {
    local example_path="$1"
    local manifest_path="$example_path/Package.swift"
    local example_name
    example_name="$(basename "$example_path" .swiftpm)"

    if grep -q 'path: "../.."' "$manifest_path"; then
        echo "error: $example_name must use the public package URL, not a local path dependency." >&2
        exit 1
    fi

    if ! grep -q "$package_url" "$manifest_path"; then
        echo "error: $example_name is missing public package URL $package_url." >&2
        exit 1
    fi

    if ! grep -q 'import AppleProductTypes' "$manifest_path"; then
        echo "error: $example_name must import AppleProductTypes for Swift Playgrounds app support." >&2
        exit 1
    fi

    if ! grep -q '\.iOSApplication' "$manifest_path"; then
        echo "error: $example_name must declare an iOSApplication product for Swift Playgrounds." >&2
        exit 1
    fi
}

export DEVELOPER_DIR="${DEVELOPER_DIR:-/Applications/Xcode.app/Contents/Developer}"

for example_name in "${examples[@]}"; do
    source_path="$repo_root/Examples/$example_name.swiftpm"
    validate_manifest "$source_path"

    build_path="$source_path"
    cleanup_path=""

    if [[ "$dependency_mode" == "local" ]]; then
        cleanup_path="$(mktemp -d "${TMPDIR:-/tmp}/${example_name}.XXXXXX")"
        build_path="$cleanup_path/$example_name.swiftpm"
        mkdir -p "$build_path"
        rsync -a \
            --exclude '.build' \
            --exclude '.swiftpm' \
            --exclude 'Package.resolved' \
            "$source_path/" \
            "$build_path/"
        perl -0pi -e "s#\\.package\\(url: \"$package_url\", from: \"0\\.1\\.0\"\\)#.package(name: \"SwiftSankeyDiagram\", path: \"$repo_root\")#" "$build_path/Package.swift"
    fi

    derived_data_path="$build_path/.build/xcode-derived-data"
    if [[ -n "$user_clang_module_cache_path" ]]; then
        export CLANG_MODULE_CACHE_PATH="$user_clang_module_cache_path"
    else
        export CLANG_MODULE_CACHE_PATH="$build_path/.build/clang-module-cache"
    fi
    rm -rf "$derived_data_path"

    echo "Building $example_name ($dependency_mode dependency)..."
    if ! (
        cd "$build_path"
        xcodebuild \
            -quiet \
            -scheme "$example_name" \
            -destination 'generic/platform=iOS Simulator' \
            -derivedDataPath "$derived_data_path" \
            build
    ); then
        if [[ -n "$cleanup_path" ]]; then
            rm -rf "$cleanup_path"
        fi
        exit 1
    fi

    if [[ -n "$cleanup_path" ]]; then
        rm -rf "$cleanup_path"
    fi
done
