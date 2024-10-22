package co.stackfinance.call_watcher.call_watcher

import android.content.Context
import android.content.Intent
import android.net.Uri
import android.provider.CallLog
import androidx.annotation.NonNull
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import java.util.*

class CallWatcherPlugin : FlutterPlugin, MethodChannel.MethodCallHandler {
    private lateinit var context: Context
    private lateinit var channel: MethodChannel
    private var lastDialedNumber: String? = null
    private val callLog = mutableListOf<CallLogEntry>()

    override fun onAttachedToEngine(@NonNull flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
        context = flutterPluginBinding.applicationContext
        channel = MethodChannel(flutterPluginBinding.binaryMessenger, "call_watcher")
        channel.setMethodCallHandler(this)
    }

    override fun onDetachedFromEngine(@NonNull binding: FlutterPlugin.FlutterPluginBinding) {
        channel.setMethodCallHandler(null)
    }

    override fun onMethodCall(@NonNull call: MethodCall, @NonNull result: MethodChannel.Result) {
        when (call.method) {
            "initiateCall" -> {
                val number = call.arguments as? String 
                  ?: return result.error("INVALID_ARGUMENT", "Number not provided", null)
                if (number != null) {
                    val success = initiateCall(number)
                    result.success(if (success) 0 else 1)
                } else {
                    result.error("INVALID_ARGUMENT", "Number not provided", null)
                }
            }
            "getLastDialedNumber" -> {
                result.success(lastDialedNumber)
            }
            "getCallLog" -> {
                result.success(callLog.map { it.toMap() })
            }
            "clearCallLog" -> {
                try {
                    clearCallLog()
                    result.success(0)
                } catch (e: Exception) {
                    result.error("CLEAR_FAILED", e.message, null)
                }
            }
            else -> result.notImplemented()
        }
    }

    private fun initiateCall(number: String): Boolean {
        return try {
            val intent = Intent(Intent.ACTION_CALL)
            intent.data = Uri.parse("tel:$number")
            intent.flags = Intent.FLAG_ACTIVITY_NEW_TASK
            context.startActivity(intent)

            lastDialedNumber = number
            callLog.add(
                CallLogEntry(
                    UUID.randomUUID().toString(),
                    number,
                    null,
                    Date(),
                    null,
                    isOutgoing = true
                )
            )
            true
        } catch (e: Exception) {
            false
        }
    }

    private fun clearCallLog() {
        callLog.clear()
    }
}

data class CallLogEntry(
    val id: String,
    val number: String,
    val contactName: String?,
    val date: Date?,
    val duration: Long?,
    val isOutgoing: Boolean
) {
    fun toMap(): Map<String, Any?> {
        return mapOf(
            "id" to id,
            "number" to number,
            "contactName" to contactName,
            "date" to date?.toString(),
            "duration" to duration,
            "isOutgoing" to isOutgoing
        )
    }
}
