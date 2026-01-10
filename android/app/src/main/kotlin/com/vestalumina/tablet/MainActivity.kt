// FILE: android/app/src/main/kotlin/com/villaos/tablet/MainActivity.kt
// OPIS: Native Android kiosk mode implementacija
// VERZIJA: 1.0
// DATUM: 2025-01-10
// NAPOMENA: Zamijeni postojeći MainActivity.kt s ovim

package com.villaos.tablet

import android.app.ActivityManager
import android.app.admin.DevicePolicyManager
import android.content.ComponentName
import android.content.Context
import android.content.Intent
import android.os.Build
import android.os.Bundle
import android.provider.Settings
import android.view.View
import android.view.WindowInsets
import android.view.WindowInsetsController
import android.view.WindowManager
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    
    companion object {
        private const val CHANNEL = "com.villaos.tablet/kiosk"
        private const val TAG = "VillaOS_Kiosk"
    }
    
    private var isInKioskMode = false
    
    // ============================================================
    // LIFECYCLE
    // ============================================================
    
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        
        // Drži ekran upaljen po defaultu
        window.addFlags(WindowManager.LayoutParams.FLAG_KEEP_SCREEN_ON)
    }
    
    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        
        // Setup Method Channel
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL)
            .setMethodCallHandler { call, result ->
                when (call.method) {
                    "enableKioskMode" -> {
                        val success = enableKioskMode()
                        result.success(success)
                    }
                    "disableKioskMode" -> {
                        val success = disableKioskMode()
                        result.success(success)
                    }
                    "isInKioskMode" -> {
                        result.success(isInKioskMode)
                    }
                    "keepScreenOn" -> {
                        val enabled = call.argument<Boolean>("enabled") ?: true
                        keepScreenOn(enabled)
                        result.success(true)
                    }
                    "hideSystemBars" -> {
                        hideSystemBars()
                        result.success(true)
                    }
                    "showSystemBars" -> {
                        showSystemBars()
                        result.success(true)
                    }
                    "setAsDefaultLauncher" -> {
                        openLauncherSettings()
                        result.success(true)
                    }
                    else -> {
                        result.notImplemented()
                    }
                }
            }
    }
    
    // ============================================================
    // KIOSK MODE - LOCK TASK
    // ============================================================
    
    private fun enableKioskMode(): Boolean {
        return try {
            // Metoda 1: Start Lock Task (ne zahtijeva Device Owner)
            // Ovo radi za Screen Pinning
            startLockTask()
            isInKioskMode = true
            
            // Sakrij system bars
            hideSystemBars()
            
            // Drži ekran upaljen
            keepScreenOn(true)
            
            android.util.Log.d(TAG, "Kiosk mode ENABLED")
            true
        } catch (e: Exception) {
            android.util.Log.e(TAG, "Failed to enable kiosk mode: ${e.message}")
            false
        }
    }
    
    private fun disableKioskMode(): Boolean {
        return try {
            // Zaustavi Lock Task
            stopLockTask()
            isInKioskMode = false
            
            // Prikaži system bars
            showSystemBars()
            
            android.util.Log.d(TAG, "Kiosk mode DISABLED")
            true
        } catch (e: Exception) {
            android.util.Log.e(TAG, "Failed to disable kiosk mode: ${e.message}")
            false
        }
    }
    
    // ============================================================
    // SYSTEM BARS CONTROL
    // ============================================================
    
    private fun hideSystemBars() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.R) {
            // Android 11+
            window.insetsController?.let { controller ->
                controller.hide(WindowInsets.Type.statusBars() or WindowInsets.Type.navigationBars())
                controller.systemBarsBehavior = 
                    WindowInsetsController.BEHAVIOR_SHOW_TRANSIENT_BARS_BY_SWIPE
            }
        } else {
            // Starije verzije
            @Suppress("DEPRECATION")
            window.decorView.systemUiVisibility = (
                View.SYSTEM_UI_FLAG_IMMERSIVE_STICKY
                or View.SYSTEM_UI_FLAG_FULLSCREEN
                or View.SYSTEM_UI_FLAG_HIDE_NAVIGATION
                or View.SYSTEM_UI_FLAG_LAYOUT_STABLE
                or View.SYSTEM_UI_FLAG_LAYOUT_HIDE_NAVIGATION
                or View.SYSTEM_UI_FLAG_LAYOUT_FULLSCREEN
            )
        }
    }
    
    private fun showSystemBars() {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.R) {
            window.insetsController?.show(
                WindowInsets.Type.statusBars() or WindowInsets.Type.navigationBars()
            )
        } else {
            @Suppress("DEPRECATION")
            window.decorView.systemUiVisibility = View.SYSTEM_UI_FLAG_VISIBLE
        }
    }
    
    // ============================================================
    // SCREEN CONTROL
    // ============================================================
    
    private fun keepScreenOn(enabled: Boolean) {
        if (enabled) {
            window.addFlags(WindowManager.LayoutParams.FLAG_KEEP_SCREEN_ON)
        } else {
            window.clearFlags(WindowManager.LayoutParams.FLAG_KEEP_SCREEN_ON)
        }
    }
    
    // ============================================================
    // LAUNCHER SETTINGS
    // ============================================================
    
    private fun openLauncherSettings() {
        try {
            val intent = Intent(Settings.ACTION_HOME_SETTINGS)
            startActivity(intent)
        } catch (e: Exception) {
            android.util.Log.e(TAG, "Failed to open launcher settings: ${e.message}")
        }
    }
    
    // ============================================================
    // BACK BUTTON OVERRIDE
    // ============================================================
    
    @Deprecated("Deprecated in Java")
    override fun onBackPressed() {
        if (isInKioskMode) {
            // U kiosk modu, ignoriraj Back button
            android.util.Log.d(TAG, "Back button pressed but ignored (kiosk mode)")
            return
        }
        super.onBackPressed()
    }
    
    // ============================================================
    // PREVENT LEAVING APP
    // ============================================================
    
    override fun onPause() {
        super.onPause()
        
        if (isInKioskMode) {
            // Ako je u kiosk modu i netko pokuša izaći, vrati se
            val activityManager = getSystemService(Context.ACTIVITY_SERVICE) as ActivityManager
            activityManager.moveTaskToFront(taskId, 0)
            android.util.Log.d(TAG, "Prevented leaving app (kiosk mode)")
        }
    }
    
    override fun onWindowFocusChanged(hasFocus: Boolean) {
        super.onWindowFocusChanged(hasFocus)
        
        if (isInKioskMode && hasFocus) {
            // Ponovno sakrij system bars kad app dobije fokus
            hideSystemBars()
        }
    }
}