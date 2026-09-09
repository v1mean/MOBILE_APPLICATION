package io.jomnes.app

import android.content.pm.PackageManager
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
                    val info = packageManager.getPackageInfo(packageName, PackageManager.GET_SIGNATURES)
                    for (signature in info.signatures) {
                        val md = MessageDigest.getInstance("SHA")
                        md.update(signature.toByteArray())
                        val hash = Base64.encodeToString(md.digest(), Base64.NO_WRAP)
                        result.success(hash)
                        return@setMethodCallHandler
                    }
                } catch (e: Exception) {
                    result.error("ERROR", e.message, null)
                }
                result.success(null)
            } else {
                result.notImplemented()
            }
        }
    }
}
