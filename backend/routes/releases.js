const express = require('express');
const axios = require('axios');
const QRCode = require('qrcode');
const router = express.Router();

// GitHub repository information
const GITHUB_OWNER = 'shivanandham'; // Your GitHub username
const GITHUB_REPO = 'pregnancy-assistant';

/**
 * Get latest release information from GitHub
 */
router.get('/latest', async (req, res) => {
  try {
    const response = await axios.get(
      `https://api.github.com/repos/${GITHUB_OWNER}/${GITHUB_REPO}/releases/latest`,
      {
        headers: {
          'Accept': 'application/vnd.github.v3+json',
          'User-Agent': 'Luma-Pregnancy-Assistant'
        }
      }
    );

    const release = response.data;
    
    // Find the APK asset
    const apkAsset = release.assets.find(asset => 
      asset.name.endsWith('.apk')
    );

    if (!apkAsset) {
      return res.status(404).json({
        success: false,
        message: 'No APK found in latest release'
      });
    }

    const releaseInfo = {
      success: true,
      version: release.tag_name,
      name: release.name,
      published_at: release.published_at,
      download_url: apkAsset.browser_download_url,
      download_count: apkAsset.download_count,
      size: apkAsset.size,
      release_notes: release.body,
      apk_name: apkAsset.name
    };

    res.json(releaseInfo);

  } catch (error) {
    console.error('Error fetching latest release:', error);
    
    if (error.response?.status === 404) {
      return res.status(404).json({
        success: false,
        message: 'No releases found for this repository'
      });
    }

    res.status(500).json({
      success: false,
      message: 'Failed to fetch latest release information',
      error: process.env.NODE_ENV === 'development' ? error.message : undefined
    });
  }
});

/**
 * Generate QR code for latest APK download
 */
router.get('/qr', async (req, res) => {
  try {
    // Get latest release info
    const releaseResponse = await axios.get(
      `https://api.github.com/repos/${GITHUB_OWNER}/${GITHUB_REPO}/releases/latest`,
      {
        headers: {
          'Accept': 'application/vnd.github.v3+json',
          'User-Agent': 'Luma-Pregnancy-Assistant'
        }
      }
    );

    const release = releaseResponse.data;
    
    // Find the APK asset
    const apkAsset = release.assets.find(asset => 
      asset.name.endsWith('.apk')
    );

    if (!apkAsset) {
      return res.status(404).json({
        success: false,
        message: 'No APK found in latest release'
      });
    }

    // Generate QR code
    const qrCodeDataURL = await QRCode.toDataURL(apkAsset.browser_download_url, {
      width: 300,
      margin: 2,
      color: {
        dark: '#2D3748',  // Dark gray
        light: '#FFFFFF'  // White
      }
    });

    res.json({
      success: true,
      qr_code: qrCodeDataURL,
      download_url: apkAsset.browser_download_url,
      version: release.tag_name,
      name: release.name,
      published_at: release.published_at,
      download_count: apkAsset.download_count,
      size: apkAsset.size,
      apk_name: apkAsset.name
    });

  } catch (error) {
    console.error('Error generating QR code:', error);
    
    if (error.response?.status === 404) {
      return res.status(404).json({
        success: false,
        message: 'No releases found for this repository'
      });
    }

    res.status(500).json({
      success: false,
      message: 'Failed to generate QR code',
      error: process.env.NODE_ENV === 'development' ? error.message : undefined
    });
  }
});

/**
 * Get QR code as image (PNG)
 */
router.get('/qr/image', async (req, res) => {
  try {
    // Get latest release info
    const releaseResponse = await axios.get(
      `https://api.github.com/repos/${GITHUB_OWNER}/${GITHUB_REPO}/releases/latest`,
      {
        headers: {
          'Accept': 'application/vnd.github.v3+json',
          'User-Agent': 'Luma-Pregnancy-Assistant'
        }
      }
    );

    const release = releaseResponse.data;
    
    // Find the APK asset
    const apkAsset = release.assets.find(asset => 
      asset.name.endsWith('.apk')
    );

    if (!apkAsset) {
      return res.status(404).json({
        success: false,
        message: 'No APK found in latest release'
      });
    }

    // Generate QR code as PNG buffer
    const qrCodeBuffer = await QRCode.toBuffer(apkAsset.browser_download_url, {
      width: 300,
      margin: 2,
      color: {
        dark: '#2D3748',  // Dark gray
        light: '#FFFFFF'  // White
      }
    });

    res.set({
      'Content-Type': 'image/png',
      'Content-Length': qrCodeBuffer.length,
      'Cache-Control': 'public, max-age=300' // Cache for 5 minutes
    });

    res.send(qrCodeBuffer);

  } catch (error) {
    console.error('Error generating QR code image:', error);
    res.status(500).json({
      success: false,
      message: 'Failed to generate QR code image'
    });
  }
});

/**
 * Get all releases (for debugging/admin purposes)
 */
router.get('/all', async (req, res) => {
  try {
    const response = await axios.get(
      `https://api.github.com/repos/${GITHUB_OWNER}/${GITHUB_REPO}/releases`,
      {
        headers: {
          'Accept': 'application/vnd.github.v3+json',
          'User-Agent': 'Luma-Pregnancy-Assistant'
        }
      }
    );

    const releases = response.data.map(release => {
      const apkAsset = release.assets.find(asset => 
        asset.name.endsWith('.apk') && asset.name.includes('app-release')
      );

      return {
        version: release.tag_name,
        name: release.name,
        published_at: release.published_at,
        download_url: apkAsset?.browser_download_url || null,
        download_count: apkAsset?.download_count || 0,
        size: apkAsset?.size || 0,
        apk_name: apkAsset?.name || null,
        has_apk: !!apkAsset
      };
    });

    res.json({
      success: true,
      releases: releases
    });

  } catch (error) {
    console.error('Error fetching all releases:', error);
    res.status(500).json({
      success: false,
      message: 'Failed to fetch releases',
      error: process.env.NODE_ENV === 'development' ? error.message : undefined
    });
  }
});

module.exports = router;
