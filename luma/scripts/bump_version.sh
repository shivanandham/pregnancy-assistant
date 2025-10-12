#!/bin/bash

# Version bump script for Luma app
# Usage: ./bump_version.sh [patch|minor|major]

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Get script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_DIR="$(dirname "$SCRIPT_DIR")"
PUBSPEC_FILE="$PROJECT_DIR/pubspec.yaml"

# Check if pubspec.yaml exists
if [ ! -f "$PUBSPEC_FILE" ]; then
    echo -e "${RED}Error: pubspec.yaml not found at $PUBSPEC_FILE${NC}"
    exit 1
fi

# Function to get current version
get_current_version() {
    grep "^version:" "$PUBSPEC_FILE" | sed 's/version: //' | tr -d ' '
}

# Function to parse version
parse_version() {
    local version=$1
    local version_part=$(echo $version | cut -d'+' -f1)
    local build_part=$(echo $version | cut -d'+' -f2)
    
    echo "$version_part|$build_part"
}

# Function to increment version
increment_version() {
    local version_part=$1
    local build_part=$2
    local bump_type=$3
    
    IFS='.' read -ra VERSION_ARRAY <<< "$version_part"
    local major=${VERSION_ARRAY[0]}
    local minor=${VERSION_ARRAY[1]}
    local patch=${VERSION_ARRAY[2]}
    
    case $bump_type in
        "patch")
            patch=$((patch + 1))
            ;;
        "minor")
            minor=$((minor + 1))
            patch=0
            ;;
        "major")
            major=$((major + 1))
            minor=0
            patch=0
            ;;
        "build")
            # Just increment build number
            ;;
        *)
            echo -e "${RED}Error: Invalid bump type. Use: patch, minor, major, or build${NC}"
            exit 1
            ;;
    esac
    
    # Always increment build number
    build_part=$((build_part + 1))
    
    echo "$major.$minor.$patch+$build_part"
}

# Function to update pubspec.yaml
update_pubspec() {
    local new_version=$1
    local temp_file=$(mktemp)
    
    sed "s/^version: .*/version: $new_version/" "$PUBSPEC_FILE" > "$temp_file"
    mv "$temp_file" "$PUBSPEC_FILE"
}

# Function to create changelog entry
create_changelog_entry() {
    local new_version=$1
    local bump_type=$2
    local timestamp=$(date '+%Y-%m-%d %H:%M:%S')
    
    local changelog_file="$PROJECT_DIR/CHANGELOG.md"
    
    # Create changelog if it doesn't exist
    if [ ! -f "$changelog_file" ]; then
        echo "# Changelog" > "$changelog_file"
        echo "" >> "$changelog_file"
        echo "All notable changes to this project will be documented in this file." >> "$changelog_file"
        echo "" >> "$changelog_file"
    fi
    
    # Add new entry
    local temp_file=$(mktemp)
    echo "# Changelog" > "$temp_file"
    echo "" >> "$temp_file"
    echo "All notable changes to this project will be documented in this file." >> "$temp_file"
    echo "" >> "$temp_file"
    echo "## [$new_version] - $timestamp" >> "$temp_file"
    echo "" >> "$temp_file"
    echo "### $bump_type" >> "$temp_file"
    echo "- Automated version bump" >> "$temp_file"
    echo "" >> "$temp_file"
    
    # Append existing content (skip header)
    tail -n +5 "$changelog_file" >> "$temp_file" 2>/dev/null || true
    
    mv "$temp_file" "$changelog_file"
}

# Main execution
main() {
    local bump_type=${1:-"build"}
    local current_version=$(get_current_version)
    
    echo -e "${BLUE}Current version: $current_version${NC}"
    
    # Parse current version
    IFS='|' read -ra VERSION_INFO <<< "$(parse_version "$current_version")"
    local version_part=${VERSION_INFO[0]}
    local build_part=${VERSION_INFO[1]}
    
    # Increment version
    local new_version=$(increment_version "$version_part" "$build_part" "$bump_type")
    
    echo -e "${YELLOW}Bumping $bump_type version...${NC}"
    echo -e "${GREEN}New version: $new_version${NC}"
    
    # Update pubspec.yaml
    update_pubspec "$new_version"
    echo -e "${GREEN}✓ Updated pubspec.yaml${NC}"
    
    # Create changelog entry
    create_changelog_entry "$new_version" "$bump_type"
    echo -e "${GREEN}✓ Updated CHANGELOG.md${NC}"
    
    echo -e "${GREEN}Version bump completed successfully!${NC}"
    echo -e "${BLUE}Next steps:${NC}"
    echo -e "  1. Review changes in pubspec.yaml and CHANGELOG.md"
    echo -e "  2. Run: flutter pub get"
    echo -e "  3. Build APK: flutter build apk --release"
    echo -e "  4. Create git tag: git tag v$version_part"
    echo -e "  5. Push tag: git push origin v$version_part"
}

# Run main function
main "$@"
