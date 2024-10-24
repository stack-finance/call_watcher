package co.stackfinance.call_watcher.call_watcher

import android.Manifest
import android.content.Context
import android.content.Intent
import android.content.pm.PackageManager
import android.net.Uri
import android.provider.CallLog
import androidx.core.content.ContextCompat
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result
import android.telecom.TelecomManager


/** CallWatcherPlugin */
class CallWatcherPlugin: FlutterPlugin, MethodCallHandler {
    private lateinit var channel: MethodChannel
    private lateinit var context: Context
    private var lastDialedNumber: String = ""

    // Data class to represent a call log entry
    data class CallLogEntry(
        val id: String,
        val number: String,
        val contactName: String?,
        val date: Long?,
        val duration: Long?,
        val isOutgoing: Boolean
    )

    override fun onAttachedToEngine(flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
        context = flutterPluginBinding.applicationContext
        channel = MethodChannel(flutterPluginBinding.binaryMessenger, "call_watcher")
        channel.setMethodCallHandler(this)
    }

    override fun onMethodCall(call: MethodCall, result: Result) {
        when (call.method) {
            "initiateCall" -> {
                try {
                    val number = call.arguments as? String ?: return result.error(
                        "INVALID_ARGUMENT", "Phone number is required", null
                    )
                    if (number != null) {
                        initiateCall(number, result)
                    } else {
                        result.error("INVALID_ARGUMENT", "Phone number is required", null)
                    }
                } catch (e: Exception) {
                    result.error("CALL_FAILED", e.message, null)
                }
            }
            "endCurrentCall" -> {
                try {
                    if (ContextCompat.checkSelfPermission(context, Manifest.permission.CALL_PHONE) 
                        != PackageManager.PERMISSION_GRANTED) {
                        result.error("PERMISSION_DENIED", "Call phone permission not granted", null)
                        return
                    }
                    
                    val telecomManager = context.getSystemService(Context.TELECOM_SERVICE) as TelecomManager
                    val success = telecomManager.endCall()
                    
                    if (success) {
                        result.success(0)  // Success
                    } else {
                        result.success(1)  // Failure
                    }
                } catch (e: Exception) {
                    result.error("END_CALL_FAILED", e.message, null)
                }
            }
            "getLastDialedNumber" -> {
                result.success(lastDialedNumber)
            }
            "getCallLog" -> {
                try {
                    val log = getCallLog()
                    result.success(log)
                } catch (e: Exception) {
                    result.error("FETCH_LOG_FAILED", e.message, null)
                }
            }
            "clearCallLog" -> {
                try {
                    clearCallLog(result)
                } catch (e: Exception) {
                    result.error("CLEAR_LOG_FAILED", e.message, null)
                }
            }
            else -> {
                result.notImplemented()
            }
        }
    }

    private fun initiateCall(number: String, result: Result) {
        // Check for CALL_PHONE permission
        if (ContextCompat.checkSelfPermission(context, Manifest.permission.CALL_PHONE) 
            != PackageManager.PERMISSION_GRANTED) {
            result.error("PERMISSION_DENIED", "Call permission not granted", null)
            return
        }

        try {
            val intent = Intent(Intent.ACTION_CALL).apply {
                data = Uri.parse("tel:$number")
                flags = Intent.FLAG_ACTIVITY_NEW_TASK
            }
            context.startActivity(intent)
            lastDialedNumber = number
            result.success(0)  // Success
        } catch (e: Exception) {
            result.success(1)  // Failure
        }
    }

    private fun getCallLog(): List<Map<String, Any?>> {
      // Check for READ_CALL_LOG permission
      if (ContextCompat.checkSelfPermission(context, Manifest.permission.READ_CALL_LOG) 
        != PackageManager.PERMISSION_GRANTED) {
        throw Exception("Call log permission not granted")
      }

      val callLogEntries = mutableListOf<Map<String, Any?>>()
      val cursor = context.contentResolver.query(
        CallLog.Calls.CONTENT_URI,
        arrayOf(
          CallLog.Calls._ID,
          CallLog.Calls.NUMBER,
          CallLog.Calls.CACHED_NAME,
          CallLog.Calls.DATE,
          CallLog.Calls.DURATION,
          CallLog.Calls.TYPE
        ),
        null,
        null,
        "${CallLog.Calls.DATE} DESC"
      )

      cursor?.use {
        while (it.moveToNext()) {
          val id = it.getString(0)
          val number = it.getString(1)
          val name = it.getString(2)
          val date = it.getLong(3)
          val duration = it.getLong(4)
          val type = it.getInt(5)
          
          val isoDate = java.text.SimpleDateFormat("yyyy-MM-dd'T'HH:mm:ss.SSS'Z'", java.util.Locale.getDefault()).apply {
            timeZone = java.util.TimeZone.getTimeZone("UTC")
          }.format(java.util.Date(date))
          
          callLogEntries.add(mapOf(
            "id" to id,
            "number" to number,
            "contactName" to name,
            "date" to isoDate,
            "duration" to duration,
            "isOutgoing" to (type == CallLog.Calls.OUTGOING_TYPE)
          ))
        }
      }

      return callLogEntries
    }

    private fun clearCallLog(result: Result) {
        // Check for WRITE_CALL_LOG permission
        if (ContextCompat.checkSelfPermission(context, Manifest.permission.WRITE_CALL_LOG) 
            != PackageManager.PERMISSION_GRANTED) {
            throw Exception("Write call log permission not granted")
        }

        try {
            context.contentResolver.delete(CallLog.Calls.CONTENT_URI, null, null)
            result.success(0)  // Success
        } catch (e: Exception) {
            throw Exception("Failed to clear call log: ${e.message}")
        }
    }

    override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        channel.setMethodCallHandler(null)
    }
}