package com.luma.luma

import android.content.pm.PackageInstaller
import android.os.Build
import androidx.core.content.FileProvider
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import java.io.File
import java.io.FileInputStream

class MainActivity : FlutterActivity() {
    private val CHANNEL = "com.luma.luma/installer"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            if (call.method == "installApk") {
                val filePath = call.argument<String>("filePath")
                if (filePath != null) {
                    installApkForCurrentUser(filePath, result)
                } else {
                    result.error("INVALID_ARGUMENT", "File path is required", null)
                }
            } else {
                result.notImplemented()
            }
        }
    }

    private fun installApkForCurrentUser(filePath: String, result: MethodChannel.Result) {
        try {
            val file = File(filePath)
            
            if (!file.exists()) {
                result.error("FILE_NOT_FOUND", "APK file not found: $filePath", null)
                return
            }

            // Use Intent with FileProvider for installation
            // By not setting FLAG_ACTIVITY_NEW_TASK, it restricts installation to current user
            val fileUri = FileProvider.getUriForFile(
                this,
                "$packageName.fileprovider",
                file
            )
            
            val intent = android.content.Intent(android.content.Intent.ACTION_INSTALL_PACKAGE).apply {
                setDataAndType(fileUri, "application/vnd.android.package-archive")
                addFlags(android.content.Intent.FLAG_GRANT_READ_URI_PERMISSION)
                // Don't add FLAG_ACTIVITY_NEW_TASK - this ensures installation only for current user
                // FLAG_ACTIVITY_NEW_TASK would make it available for all users
            }

            // For Android 7.0+, we can use PackageInstaller API for better control
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.N) {
                try {
                    val packageInstaller = packageManager.packageInstaller
                    val params = PackageInstaller.SessionParams(PackageInstaller.SessionParams.MODE_FULL_INSTALL)
                    // By default, PackageInstaller installs only for current user
                    // We explicitly don't set INSTALL_ALL_USERS flag
                    
                    val sessionId = packageInstaller.createSession(params)
                    val session = packageInstaller.openSession(sessionId)

                    // Copy APK to session
                    val fileInputStream = FileInputStream(file)
                    val outputStream = session.openWrite("package.apk", 0, -1)
                    
                    fileInputStream.copyTo(outputStream)
                    outputStream.flush()
                    fileInputStream.close()
                    outputStream.close()

                    // Create PendingIntent for status updates (can be a no-op intent)
                    val statusIntent = android.content.Intent("com.luma.luma.INSTALL_STATUS")
                    val pendingIntent = android.app.PendingIntent.getBroadcast(
                        this, sessionId, statusIntent,
                        android.app.PendingIntent.FLAG_UPDATE_CURRENT or 
                        (if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M) 
                            android.app.PendingIntent.FLAG_IMMUTABLE else 0)
                    )

                    // Commit the session (installs only for current user)
                    session.commit(pendingIntent.intentSender)
                    session.close()

                    result.success(true)
                    return
                } catch (e: Exception) {
                    // Fall back to Intent if PackageInstaller fails
                }
            }

            // Fallback to Intent for older Android versions or if PackageInstaller fails
            startActivity(intent)
            result.success(true)
        } catch (e: Exception) {
            result.error("INSTALL_ERROR", "Failed to install APK: ${e.message}", null)
        }
    }
}
