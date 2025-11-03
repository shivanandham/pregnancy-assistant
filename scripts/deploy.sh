#!/bin/bash

# Deployment script for Luma app
# Usage: ./deploy.sh [patch|minor|major]

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
LUMA_DIR="$PROJECT_DIR/luma"
BUMP_SCRIPT="$LUMA_DIR/scripts/bump_version.sh"

# Check if we're in the right directory
if [ ! -d "$LUMA_DIR" ]; then
    echo -e "${RED}Error: Luma directory not found at $LUMA_DIR${NC}"
    exit 1
fi

# Check if bump_version.sh exists
if [ ! -f "$BUMP_SCRIPT" ]; then
    echo -e "${RED}Error: bump_version.sh not found at $BUMP_SCRIPT${NC}"
    exit 1
fi

# Function to print usage
print_usage() {
    echo -e "${BLUE}Usage: $0 [patch|minor|major]${NC}"
    echo -e "${YELLOW}  patch  - Increment patch version (1.0.0 -> 1.0.1)${NC}"
    echo -e "${YELLOW}  minor  - Increment minor version (1.0.0 -> 1.1.0)${NC}"
    echo -e "${YELLOW}  major  - Increment major version (1.0.0 -> 2.0.0)${NC}"
    echo -e "${YELLOW}  build  - Just increment build number (default)${NC}"
}

# Function to check git status
check_git_status() {
    echo -e "${BLUE}Checking git status...${NC}"
    
    # Check if we're in a git repository
    if [ ! -d ".git" ]; then
        echo -e "${RED}Error: Not in a git repository${NC}"
        exit 1
    fi
    
    # Check if there are uncommitted changes
    if [ -n "$(git status --porcelain)" ]; then
        echo -e "${YELLOW}Warning: You have uncommitted changes${NC}"
        echo -e "${YELLOW}Do you want to continue? (y/N)${NC}"
        read -r response
        if [[ ! "$response" =~ ^[Yy]$ ]]; then
            echo -e "${RED}Deployment cancelled${NC}"
            exit 1
        fi
    fi
    
    # Check if we're on main branch
    current_branch=$(git branch --show-current)
    if [ "$current_branch" != "main" ]; then
        echo -e "${YELLOW}Warning: You're not on the main branch (currently on: $current_branch)${NC}"
        echo -e "${YELLOW}Do you want to continue? (y/N)${NC}"
        read -r response
        if [[ ! "$response" =~ ^[Yy]$ ]]; then
            echo -e "${RED}Deployment cancelled${NC}"
            exit 1
        fi
    fi
}

# Function to bump version
bump_version() {
    local bump_type=${1:-"build"}
    
    echo -e "${BLUE}Bumping version ($bump_type)...${NC}"
    cd "$LUMA_DIR"
    
    if ! bash "$BUMP_SCRIPT" "$bump_type"; then
        echo -e "${RED}Version bump failed${NC}"
        exit 1
    fi
    
    cd "$PROJECT_DIR"
    echo -e "${GREEN}✓ Version bumped successfully${NC}"
}

# Function to build APK
build_apk() {
    echo -e "${BLUE}Building release APK...${NC}"
    cd "$LUMA_DIR"
    
    # Get Flutter dependencies
    echo -e "${YELLOW}Getting Flutter dependencies...${NC}"
    if ! flutter pub get; then
        echo -e "${RED}Failed to get Flutter dependencies${NC}"
        exit 1
    fi
    
    # Build APK (uses hardcoded production URL from backend_config.dart)
    echo -e "${YELLOW}Building APK...${NC}"
    if ! flutter build apk --release; then
        echo -e "${RED}APK build failed${NC}"
        exit 1
    fi
    
    cd "$PROJECT_DIR"
    echo -e "${GREEN}✓ APK built successfully${NC}"
}

# Function to create git tag
create_git_tag() {
    local version=$1
    
    echo -e "${BLUE}Creating git tag...${NC}"
    
    # Get version from pubspec.yaml
    local version_part=$(grep "^version:" "$LUMA_DIR/pubspec.yaml" | sed 's/version: //' | cut -d'+' -f1)
    local tag_name="v$version_part"
    
    # Check if tag already exists
    if git tag -l | grep -q "^$tag_name$"; then
        echo -e "${YELLOW}Tag $tag_name already exists${NC}"
        echo -e "${YELLOW}Do you want to delete and recreate it? (y/N)${NC}"
        read -r response
        if [[ "$response" =~ ^[Yy]$ ]]; then
            git tag -d "$tag_name"
            git push origin ":refs/tags/$tag_name" 2>/dev/null || true
        else
            echo -e "${RED}Deployment cancelled${NC}"
            exit 1
        fi
    fi
    
    # Create and push tag
    git add .
    git commit -m "Release $tag_name" || true
    git tag "$tag_name"
    git push origin main
    git push origin "$tag_name"
    
    echo -e "${GREEN}✓ Git tag $tag_name created and pushed${NC}"
}

# Function to show next steps
show_next_steps() {
    local version_part=$(grep "^version:" "$LUMA_DIR/pubspec.yaml" | sed 's/version: //' | cut -d'+' -f1)
    local tag_name="v$version_part"
    local apk_path="$LUMA_DIR/build/app/outputs/flutter-apk/app-release.apk"
    
    echo -e "${GREEN}🎉 Deployment completed successfully!${NC}"
    echo -e "${BLUE}📋 What happens next:${NC}"
    echo -e "  ✅ Git tag $tag_name created and pushed"
    echo -e "  🚀 GitHub Actions will automatically:"
    echo -e "     • Build the APK in the cloud"
    echo -e "     • Create a GitHub release"
    echo -e "     • Upload the APK"
    echo -e "     • Generate release notes from CHANGELOG.md"
    echo -e ""
    echo -e "${YELLOW}📱 Local APK: $apk_path${NC}"
    echo -e "${YELLOW}🏷️  Tag: $tag_name${NC}"
    echo -e "${BLUE}🔗 Monitor progress: https://github.com/shivanandham/pregnancy-assistant/actions${NC}"
    echo -e "${BLUE}📦 Release will appear at: https://github.com/shivanandham/pregnancy-assistant/releases${NC}"
    echo -e ""
    echo -e "${GREEN}⏱️  The release will be ready in 2-3 minutes!${NC}"
}

# Main execution
main() {
    local bump_type=${1:-"build"}
    
    echo -e "${BLUE}🚀 Starting Luma app deployment...${NC}"
    echo -e "${YELLOW}Bump type: $bump_type${NC}"
    
    # Validate bump type
    case $bump_type in
        "patch"|"minor"|"major"|"build")
            ;;
        *)
            echo -e "${RED}Error: Invalid bump type '$bump_type'${NC}"
            print_usage
            exit 1
            ;;
    esac
    
    # Run deployment steps
    check_git_status
    bump_version "$bump_type"
    create_git_tag
    
    show_next_steps
}

# Run main function
main "$@"
