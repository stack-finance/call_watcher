package co.stackfinance.call_watcher.call_watcher

import android.Manifest
import android.app.Activity
import android.content.Context
import android.content.Intent
import android.content.pm.PackageManager
import android.net.Uri
import android.provider.CallLog
import android.telecom.TelecomManager
import androidx.core.app.ActivityCompat
import androidx.core.content.ContextCompat
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.embedding.engine.plugins.activity.ActivityAware
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result
import io.flutter.plugin.common.PluginRegistry

class CallPermissionManager(
    private val context: Context
) : PluginRegistry.RequestPermissionsResultListener {
    
    companion object {
        private const val CALL_PERMISSION_REQUEST_CODE = 100
        private const val CALL_LOG_READ_REQUEST_CODE = 101
        private const val CALL_LOG_WRITE_REQUEST_CODE = 102
        
        private val CALL_PERMISSIONS = arrayOf(
            Manifest.permission.CALL_PHONE
        )
        
        private val CALL_LOG_READ_PERMISSIONS = arrayOf(
            Manifest.permission.READ_CALL_LOG
        )
        
        private val CALL_LOG_WRITE_PERMISSIONS = arrayOf(
            Manifest.permission.READ_CALL_LOG,
            Manifest.permission.WRITE_CALL_LOG
        )
    }
    
    private var pendingResult: Result? = null
    private var pendingAction: (() -> Unit)? = null
    
    fun checkAndRequestCallPermission(activity: Activity?, result: Result, action: () -> Unit) {
        when {
            hasCallPermission() -> {
                action.invoke()
            }
            activity != null -> {
                pendingResult = result
                pendingAction = action
                ActivityCompat.requestPermissions(
                    activity,
                    CALL_PERMISSIONS,
                    CALL_PERMISSION_REQUEST_CODE
                )
            }
            else -> {
                result.error(
                    "PERMISSION_DENIED",
                    "Call permission not granted and cannot request permission",
                    null
                )
            }
        }
    }
    
    fun checkAndRequestCallLogReadPermission(activity: Activity?, result: Result, action: () -> Unit) {
        when {
            hasCallLogReadPermission() -> {
                action.invoke()
            }
            activity != null -> {
                pendingResult = result
                pendingAction = action
                ActivityCompat.requestPermissions(
                    activity,
                    CALL_LOG_READ_PERMISSIONS,
                    CALL_LOG_READ_REQUEST_CODE
                )
            }
            else -> {
                result.error(
                    "PERMISSION_DENIED",
                    "Call log read permission not granted and cannot request permission",
                    null
                )
            }
        }
    }
    
    fun checkAndRequestCallLogWritePermission(activity: Activity?, result: Result, action: () -> Unit) {
        when {
            hasCallLogWritePermission() -> {
                action.invoke()
            }
            activity != null -> {
                pendingResult = result
                pendingAction = action
                ActivityCompat.requestPermissions(
                    activity,
                    CALL_LOG_WRITE_PERMISSIONS,
                    CALL_LOG_WRITE_REQUEST_CODE
                )
            }
            else -> {
                result.error(
                    "PERMISSION_DENIED",
                    "Call log write permission not granted and cannot request permission",
                    null
                )
            }
        }
    }
    
    private fun hasCallPermission(): Boolean {
        return hasPermissions(CALL_PERMISSIONS)
    }
    
    private fun hasCallLogReadPermission(): Boolean {
        return hasPermissions(CALL_LOG_READ_PERMISSIONS)
    }
    
    private fun hasCallLogWritePermission(): Boolean {
        return hasPermissions(CALL_LOG_WRITE_PERMISSIONS)
    }
    
    private fun hasPermissions(permissions: Array<String>): Boolean {
        return permissions.all {
            ContextCompat.checkSelfPermission(context, it) == PackageManager.PERMISSION_GRANTED
        }
    }
    
    override fun onRequestPermissionsResult(
        requestCode: Int,
        permissions: Array<out String>,
        grantResults: IntArray
    ): Boolean {
        when (requestCode) {
            CALL_PERMISSION_REQUEST_CODE,
            CALL_LOG_READ_REQUEST_CODE,
            CALL_LOG_WRITE_REQUEST_CODE -> {
                if (grantResults.isNotEmpty() && 
                    grantResults.all { it == PackageManager.PERMISSION_GRANTED }) {
                    pendingAction?.invoke()
                } else {
                    pendingResult?.error(
                        "PERMISSION_DENIED",
                        "Required permissions were not granted",
                        null
                    )
                }
                pendingResult = null
                pendingAction = null
                return true
            }
        }
        return false
    }
}

class CallWatcherPlugin: FlutterPlugin, MethodCallHandler, ActivityAware {
    private lateinit var channel: MethodChannel
    private lateinit var context: Context
    private var activity: Activity? = null
    private lateinit var permissionManager: CallPermissionManager
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
        permissionManager = CallPermissionManager(context)
    }

    override fun onMethodCall(call: MethodCall, result: Result) {
        when (call.method) {
            "initiateCall" -> {
                val number = call.arguments as? String ?: return result.error(
                    "INVALID_ARGUMENT", "Phone number is required", null
                )
                
                permissionManager.checkAndRequestCallPermission(activity, result) {
                    initiateCall(number, result)
                }
            }
            "endCurrentCall" -> {
                permissionManager.checkAndRequestCallPermission(activity, result) {
                    endCurrentCall(result)
                }
            }
            "getCallLog" -> {
                permissionManager.checkAndRequestCallLogReadPermission(activity, result) {
                    try {
                        val log = getCallLog()
                        result.success(log)
                    } catch (e: Exception) {
                        result.error("FETCH_LOG_FAILED", e.message, null)
                    }
                }
            }

            "queryCallLog" -> {
                permissionManager.checkAndRequestCallLogReadPermission(activity, result) {
                    try {
                        @Suppress("UNCHECKED_CAST")
                        val filters = call.arguments as? Map<String, Any?> 
                            ?: return@checkAndRequestCallLogReadPermission result.error(
                                "INVALID_ARGUMENT",
                                "Filters must be provided as a map",
                                null
                            )
                        
                        val log = queryCallLogs(filters)
                        result.success(log)
                    } catch (e: Exception) {
                        result.error("QUERY_LOG_FAILED", e.message, null)
                    }
                }            
            }

            "clearCallLog" -> {
                permissionManager.checkAndRequestCallLogWritePermission(activity, result) {
                    clearCallLog(result)
                }
            }
            "getLastDialedNumber" -> {
                result.success(lastDialedNumber)
            }
            else -> result.notImplemented()
        }
    }

    private fun initiateCall(number: String, result: Result) {
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

    private fun endCurrentCall(result: Result) {
        try {
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

    private fun getCallLog(): List<Map<String, Any?>> {
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
                
                val isoDate = java.text.SimpleDateFormat("yyyy-MM-dd'T'HH:mm:ss.SSS'Z'", 
                    java.util.Locale.getDefault()).apply {
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

        // Update the last dailed outgoing number 
        if (callLogEntries.isNotEmpty()) {
            val lastOutgoingCall = callLogEntries.firstOrNull { it["isOutgoing"] == true }
            lastDialedNumber = lastOutgoingCall?.get("number") as? String ?: lastDialedNumber
        }

        return callLogEntries
    }

    private fun clearCallLog(result: Result) {
        try {
            context.contentResolver.delete(CallLog.Calls.CONTENT_URI, null, null)
            result.success(0)  // Success
        } catch (e: Exception) {
            result.error("CLEAR_LOG_FAILED", "Failed to clear call log: ${e.message}", null)
        }
    }

    private fun queryCallLogs(filters: Map<String, Any?>): List<Map<String, Any?>> {
        val callLogEntries = mutableListOf<Map<String, Any?>>()
        
        // Build the selection criteria and arguments
        val selectionCriteria = mutableListOf<String>()
        val selectionArgs = mutableListOf<String>()
        
        // Handle date range
        filters["dateFrom"]?.let { dateFrom ->
            selectionCriteria.add("${CallLog.Calls.DATE} >= ?")
            // Convert ISO date string to milliseconds
            val date = java.text.SimpleDateFormat("yyyy-MM-dd'T'HH:mm:ss.SSS'Z'", 
                java.util.Locale.getDefault()).apply {
                timeZone = java.util.TimeZone.getTimeZone("UTC")
            }.parse(dateFrom as String)?.time.toString()
            selectionArgs.add(date)
        }
        
        filters["dateTo"]?.let { dateTo ->
            selectionCriteria.add("${CallLog.Calls.DATE} <= ?")
            val date = java.text.SimpleDateFormat("yyyy-MM-dd'T'HH:mm:ss.SSS'Z'", 
                java.util.Locale.getDefault()).apply {
                timeZone = java.util.TimeZone.getTimeZone("UTC")
            }.parse(dateTo as String)?.time.toString()
            selectionArgs.add(date)
        }
        
        // Handle duration range
        filters["durationFrom"]?.let { durationFrom ->
            selectionCriteria.add("${CallLog.Calls.DURATION} >= ?")
            selectionArgs.add((durationFrom as Number).toString())
        }
        
        filters["durationTo"]?.let { durationTo ->
            selectionCriteria.add("${CallLog.Calls.DURATION} <= ?")
            selectionArgs.add((durationTo as Number).toString())
        }
        
        // Handle name filter with LIKE query
        filters["name"]?.let { name ->
            selectionCriteria.add("${CallLog.Calls.CACHED_NAME} LIKE ?")
            selectionArgs.add("%${name as String}%")
        }
        
        // Handle number filter with LIKE query
        filters["number"]?.let { number ->
            selectionCriteria.add("${CallLog.Calls.NUMBER} LIKE ?")
            selectionArgs.add("%${number as String}%")
        }
        
        // Handle call type (isOutgoing)
        filters["isOutgoing"]?.let { isOutgoing ->
            selectionCriteria.add("${CallLog.Calls.TYPE} = ?")
            selectionArgs.add(
                if (isOutgoing as Boolean) 
                    CallLog.Calls.OUTGOING_TYPE.toString() 
                else 
                    CallLog.Calls.INCOMING_TYPE.toString()
            )
        }
        
        // Combine all criteria
        val selection = if (selectionCriteria.isEmpty()) null 
            else selectionCriteria.joinToString(" AND ")
        
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
            selection,
            if (selectionArgs.isEmpty()) null else selectionArgs.toTypedArray(),
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
                
                val isoDate = java.text.SimpleDateFormat("yyyy-MM-dd'T'HH:mm:ss.SSS'Z'", 
                    java.util.Locale.getDefault()).apply {
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

    override fun onAttachedToActivity(binding: ActivityPluginBinding) {
        activity = binding.activity
        binding.addRequestPermissionsResultListener(permissionManager)
    }

    override fun onDetachedFromActivityForConfigChanges() {
        activity = null
    }

    override fun onReattachedToActivityForConfigChanges(binding: ActivityPluginBinding) {
        activity = binding.activity
        binding.addRequestPermissionsResultListener(permissionManager)
    }

    override fun onDetachedFromActivity() {
        activity = null
    }

    override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        channel.setMethodCallHandler(null)
    }
}