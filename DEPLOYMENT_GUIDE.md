# Luma App Deployment Guide

This guide explains how to deploy and distribute the Luma pregnancy assistant app using our self-managed deployment system.

## 🚀 Quick Start

### For Developers (Deploying Updates)

1. **Deploy a new version:**
   ```bash
   ./scripts/deploy.sh patch  # For bug fixes
   ./scripts/deploy.sh minor  # For new features
   ./scripts/deploy.sh major  # For breaking changes
   ./scripts/deploy.sh build  # Just increment build number
   ```

2. **That's it!** GitHub Actions automatically:
   - Builds the APK in the cloud
   - Creates a GitHub release
   - Uploads the APK
   - Generates release notes from CHANGELOG.md

### For Users (Installing/Updating)

1. **Initial Installation:**
   - Download APK from [GitHub Releases](https://github.com/shivanandham/pregnancy-assistant/releases)
   - Enable "Install unknown apps" in Android settings
   - Install the APK

2. **Automatic Updates:**
   - App checks for updates on startup
   - Shows update dialog when available
   - Tap "Download & Install" to update

## 📋 System Overview

### Architecture
- **Distribution**: GitHub Releases (no Play Store needed)
- **Build**: GitHub Actions (automated cloud builds)
- **Update Check**: GitHub API integration
- **Download**: Direct APK download from releases
- **Installation**: Android package installer
- **Versioning**: Semantic versioning with automated bumping

### Key Components

1. **Version Management** (`luma/scripts/bump_version.sh`)
   - Automatically increments version numbers
   - Updates `pubspec.yaml` and `CHANGELOG.md`
   - Supports patch, minor, major, and build increments

2. **Update Service** (`luma/lib/services/update_service.dart`)
   - Checks GitHub Releases API for new versions
   - Compares versions and determines if update is needed
   - Caches results to avoid excessive API calls

3. **Update Manager** (`luma/lib/services/update_manager.dart`)
   - Handles APK download and installation
   - Manages Android permissions
   - Provides progress feedback

4. **Update UI** (`luma/lib/widgets/update_dialog.dart`)
   - Shows update notification dialog
   - Displays release notes and version info
   - Handles user interaction

5. **Deployment Script** (`scripts/deploy.sh`)
   - Orchestrates the entire deployment process
   - Creates git tags, pushes to GitHub
   - Triggers GitHub Actions for automated release

6. **GitHub Actions** (`.github/workflows/release.yml`)
   - Automatically builds APK in the cloud
   - Creates GitHub releases with proper formatting
   - Uploads APK and generates release notes

## 🔧 Configuration

### GitHub Actions Setup

The deployment system uses GitHub Actions for automated builds and releases. The workflow is configured in `.github/workflows/release.yml` and triggers automatically when you push a version tag.

**Required GitHub Settings:**
- Repository must be public or have GitHub Actions enabled
- No additional secrets or tokens needed (uses built-in `GITHUB_TOKEN`)
- Flutter and Java are automatically set up in the cloud

**Workflow Features:**
- ✅ Builds APK using Flutter 3.9.2
- ✅ Generates release notes from CHANGELOG.md
- ✅ Creates GitHub release with proper formatting
- ✅ Uploads APK as release asset
- ✅ Runs on every version tag push

### GitHub Repository Settings

Update these values in `luma/lib/services/update_service.dart`:

```dart
static const String _owner = 'shivanandham'; // Your GitHub username
static const String _repo = 'pregnancy-assistant'; // Your repository name
```

### Android Permissions

The following permissions are automatically configured:

- `INTERNET` - For checking updates and downloading APKs
- `REQUEST_INSTALL_PACKAGES` - For installing APKs (Android 8.0+)
- `WRITE_EXTERNAL_STORAGE` - For downloading files (Android <10)

### FileProvider Configuration

APK installation uses Android's FileProvider system:
- Configured in `AndroidManifest.xml`
- File paths defined in `res/xml/file_paths.xml`

## 📱 User Experience

### Update Flow

1. **App Startup**: Checks for updates after 2-second delay
2. **Update Available**: Shows dialog with version info and release notes
3. **User Choice**: 
   - "Download & Install" - Downloads and installs automatically
   - "Later" - Dismisses dialog, checks again next day
4. **Download**: Shows progress bar and status
5. **Installation**: Launches Android package installer
6. **Completion**: User can launch updated app

### Permissions

The app will request these permissions when needed:
- **Install Permission**: Required for APK installation
- **Storage Permission**: Required for downloading files (Android <10)

## 🛠️ Development Workflow

### Making Changes

1. **Develop features** in your local environment
2. **Test thoroughly** on device/emulator
3. **Commit changes** to git
4. **Run deployment script**:
   ```bash
   ./scripts/deploy.sh patch  # or minor/major
   ```
5. **Wait 2-3 minutes** for GitHub Actions to complete
6. **Check the release** at GitHub Releases page

### Version Bumping

The system supports semantic versioning:

- **Patch** (1.0.0 → 1.0.1): Bug fixes
- **Minor** (1.0.0 → 1.1.0): New features, backward compatible
- **Major** (1.0.0 → 2.0.0): Breaking changes
- **Build** (1.0.0+1 → 1.0.0+2): Just increment build number

### Changelog Management

The `bump_version.sh` script automatically:
- Updates `pubspec.yaml` with new version
- Creates entries in `CHANGELOG.md`
- Timestamps all changes

## 🔍 Troubleshooting

### Common Issues

**Update check fails:**
- Check internet connection
- Verify GitHub repository settings
- Ensure release exists with APK asset

**Download fails:**
- Check storage permissions
- Ensure sufficient storage space
- Verify APK URL is accessible

**Installation fails:**
- Enable "Install unknown apps" in Android settings
- Check if APK is corrupted (re-download)
- Ensure sufficient storage space

**App crashes after update:**
- Clear app data and restart
- Check for compatibility issues
- Report bug with device info

### Debug Information

Enable debug logging by checking the console output:
```bash
flutter logs
```

Look for messages from:
- `UpdateService` - API calls and version comparison
- `UpdateManager` - Download and installation progress
- `UpdateDialog` - User interaction events

## 📊 Monitoring

### Update Analytics

The system provides basic monitoring:
- Update check frequency (cached for 24 hours)
- Download success/failure rates
- Installation completion rates

### GitHub Release Metrics

Monitor via GitHub:
- Download counts per release
- User feedback in release comments
- Issue reports for specific versions

## 🔒 Security Considerations

### APK Security
- APKs are signed with debug keys (for development)
- For production, use proper signing certificates
- Consider code obfuscation for sensitive apps

### Update Security
- Downloads are over HTTPS
- APK integrity verified by Android installer
- No automatic installation without user consent

### Data Privacy
- Update checks don't send user data
- Only version information is transmitted
- No tracking or analytics by default

## 🚀 Advanced Features

### Custom Update Server

To use a custom update server instead of GitHub:

1. Modify `UpdateService._getLatestRelease()` method
2. Update API endpoint and response format
3. Ensure APK download URLs are accessible

### Staged Rollouts

For gradual rollouts:

1. Create multiple releases with different version numbers
2. Use feature flags to control update availability
3. Monitor adoption rates before full rollout

### Beta Testing

For beta releases:

1. Create separate GitHub repository for beta releases
2. Update `_owner` and `_repo` constants for beta users
3. Use different version numbering scheme

## 📚 Additional Resources

- [Flutter App Distribution](https://docs.flutter.dev/deployment/android)
- [Android Package Installer](https://developer.android.com/guide/components/intents-common#PackageInstaller)
- [GitHub Releases API](https://docs.github.com/en/rest/releases/releases)
- [Semantic Versioning](https://semver.org/)

## 🤝 Contributing

To contribute to the deployment system:

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Test thoroughly
5. Submit a pull request

## 📞 Support

For deployment issues:
- Check this guide first
- Search existing GitHub issues
- Create a new issue with detailed information
- Include device info, Android version, and error logs
