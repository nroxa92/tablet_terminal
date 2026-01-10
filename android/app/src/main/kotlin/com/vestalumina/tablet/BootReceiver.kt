// FILE: android/app/src/main/kotlin/com/villaos/tablet/BootReceiver.kt
// OPIS: Auto-start aplikacije kada se tablet upali
// VERZIJA: 1.0
// DATUM: 2025-01-10

package com.villaos.tablet

import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.util.Log

class BootReceiver : BroadcastReceiver() {
    
    companion object {
        private const val TAG = "VillaOS_Boot"
    }
    
    override fun onReceive(context: Context, intent: Intent) {
        if (intent.action == Intent.ACTION_BOOT_COMPLETED ||
            intent.action == "android.intent.action.QUICKBOOT_POWERON") {
            
            Log.d(TAG, "Boot completed - Starting VillaOS app")
            
            try {
                val launchIntent = Intent(context, MainActivity::class.java).apply {
                    addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
                    addFlags(Intent.FLAG_ACTIVITY_CLEAR_TOP)
                    addFlags(Intent.FLAG_ACTIVITY_SINGLE_TOP)
                }
                context.startActivity(launchIntent)
                
                Log.d(TAG, "VillaOS app started successfully")
            } catch (e: Exception) {
                Log.e(TAG, "Failed to start VillaOS app: ${e.message}")
            }
        }
    }
}