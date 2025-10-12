async function loadQRCode() {
    const qrLoading = document.getElementById('qr-loading');
    const qrCode = document.getElementById('qr-code');
    const releaseInfo = document.getElementById('release-info');
    const downloadBtn = document.getElementById('download-btn');
    const errorMessage = document.getElementById('error-message');
    
    // Show loading, hide other elements
    qrLoading.style.display = 'block';
    qrCode.style.display = 'none';
    releaseInfo.style.display = 'none';
    downloadBtn.style.display = 'none';
    errorMessage.style.display = 'none';

    try {
        const response = await fetch('/api/releases/qr');
        const data = await response.json();

        if (data.success) {
            // Show QR code
            qrCode.src = data.qr_code;
            qrCode.style.display = 'block';
            qrLoading.style.display = 'none';

            // Show release info
            document.getElementById('version').textContent = data.version;
            document.getElementById('published-at').textContent = new Date(data.published_at).toLocaleDateString();
            document.getElementById('download-count').textContent = data.download_count.toLocaleString();
            document.getElementById('file-size').textContent = formatFileSize(data.size);
            releaseInfo.style.display = 'block';

            // Show download button
            downloadBtn.href = data.download_url;
            downloadBtn.style.display = 'inline-block';
        } else {
            throw new Error(data.message || 'Failed to load release information');
        }
    } catch (error) {
        console.error('Error loading QR code:', error);
        qrLoading.style.display = 'none';
        document.getElementById('error-text').textContent = error.message;
        errorMessage.style.display = 'block';
    }
}

function formatFileSize(bytes) {
    if (bytes === 0) return '0 Bytes';
    const k = 1024;
    const sizes = ['Bytes', 'KB', 'MB', 'GB'];
    const i = Math.floor(Math.log(bytes) / Math.log(k));
    return parseFloat((bytes / Math.pow(k, i)).toFixed(2)) + ' ' + sizes[i];
}

// Load QR code when page loads
document.addEventListener('DOMContentLoaded', loadQRCode);
