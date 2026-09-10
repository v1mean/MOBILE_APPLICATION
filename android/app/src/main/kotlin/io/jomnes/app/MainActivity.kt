package io.jomnes.app

import android.content.pm.PackageManager
import android.os.Build
import android.util.Base64
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import java.security.MessageDigest

class MainActivity: FlutterActivity() {
    private val CHANNEL = "io.jomnes.app/hash"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            if (call.method == "getKeyHash") {
                try {
                    val signatures = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.P) {
                        val info = packageManager.getPackageInfo(packageName, PackageManager.GET_SIGNING_CERTIFICATES)
                        info.signingInfo?.apkContentsSigners
                    } else {
                        @Suppress("DEPRECATION")
                        val info = packageManager.getPackageInfo(packageName, PackageManager.GET_SIGNATURES)
                        @Suppress("DEPRECATION")
                        info.signatures
                    }

                    if (signatures != null) {
                        for (signature in signatures) {
                            val md = MessageDigest.getInstance("SHA")
                            md.update(signature.toByteArray())
                            val hash = Base64.encodeToString(md.digest(), Base64.NO_WRAP)
                            result.success(hash)
                            return@setMethodCallHandler
                        }
                    }
                } catch (e: Exception) {
                    result.error("ERROR", e.message, null)
                    return@setMethodCallHandler
                }
                result.success(null)
            } else {
                result.notImplemented()
            }
        }
    }
}
