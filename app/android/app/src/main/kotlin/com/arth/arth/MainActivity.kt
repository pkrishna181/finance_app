package com.arth.arth

import android.content.ContentResolver
import android.database.Cursor
import android.net.Uri
import android.os.Build
import android.os.Bundle
import android.provider.Telephony
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

/**
 * Minimal SMS inbox reader — replaces flutter_sms_inbox.
 * Paginated (date DESC, LIMIT/OFFSET), optional sender entity filter.
 * Returns maps: {sender, body, date_millis}. Never logs bodies.
 */
class MainActivity : FlutterActivity() {
    private val channelName = "com.arth.arth/sms_inbox"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, channelName)
            .setMethodCallHandler { call, result ->
                when (call.method) {
                    "querySmsPage" -> {
                        val limit = (call.argument<Number>("limit")?.toInt() ?: 100).coerceIn(1, 500)
                        val beforeDateMillis =
                            call.argument<Number>("before_date_millis")?.toLong()
                        @Suppress("UNCHECKED_CAST")
                        val entities =
                            (call.argument<List<String>>("entities") ?: emptyList())
                                .map { it.uppercase() }
                                .filter { it.isNotBlank() }
                        try {
                            result.success(querySmsPage(limit, beforeDateMillis, entities))
                        } catch (e: SecurityException) {
                            result.error("PERMISSION_DENIED", e.message, null)
                        } catch (e: Exception) {
                            result.error("SMS_QUERY_FAILED", e.message, null)
                        }
                    }
                    "countSms" -> {
                        @Suppress("UNCHECKED_CAST")
                        val entities =
                            (call.argument<List<String>>("entities") ?: emptyList())
                                .map { it.uppercase() }
                                .filter { it.isNotBlank() }
                        try {
                            result.success(countSms(entities))
                        } catch (e: SecurityException) {
                            result.error("PERMISSION_DENIED", e.message, null)
                        } catch (e: Exception) {
                            result.error("SMS_QUERY_FAILED", e.message, null)
                        }
                    }
                    else -> result.notImplemented()
                }
            }
    }

    private fun querySmsPage(
        limit: Int,
        beforeDateMillis: Long?,
        entities: List<String>,
    ): List<Map<String, Any?>> {
        val uri: Uri = Telephony.Sms.Inbox.CONTENT_URI
        val projection = arrayOf(
            Telephony.Sms.ADDRESS,
            Telephony.Sms.BODY,
            Telephony.Sms.DATE,
        )

        val selectionParts = ArrayList<String>()
        val selectionArgList = ArrayList<String>()
        if (entities.isNotEmpty()) {
            selectionParts.add(
                entities.joinToString(" OR ") {
                    "${Telephony.Sms.ADDRESS} LIKE ?"
                },
            )
            entities.forEach { selectionArgList.add("%$it%") }
        }
        if (beforeDateMillis != null) {
            selectionParts.add("${Telephony.Sms.DATE} < ?")
            selectionArgList.add(beforeDateMillis.toString())
        }
        val selection =
            if (selectionParts.isEmpty()) null else selectionParts.joinToString(" AND ")
        val selectionArgs =
            if (selectionArgList.isEmpty()) null else selectionArgList.toTypedArray()

        val rows = ArrayList<Map<String, Any?>>(limit)
        val cursor: Cursor? = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
            val args = Bundle().apply {
                putInt(ContentResolver.QUERY_ARG_LIMIT, limit)
                putStringArray(
                    ContentResolver.QUERY_ARG_SORT_COLUMNS,
                    arrayOf(Telephony.Sms.DATE),
                )
                putInt(
                    ContentResolver.QUERY_ARG_SORT_DIRECTION,
                    ContentResolver.QUERY_SORT_DIRECTION_DESCENDING,
                )
                if (selection != null) {
                    putString(ContentResolver.QUERY_ARG_SQL_SELECTION, selection)
                    putStringArray(
                        ContentResolver.QUERY_ARG_SQL_SELECTION_ARGS,
                        selectionArgs,
                    )
                }
            }
            contentResolver.query(uri, projection, args, null)
        } else {
            @Suppress("DEPRECATION")
            contentResolver.query(
                uri,
                projection,
                selection,
                selectionArgs,
                "${Telephony.Sms.DATE} DESC LIMIT $limit",
            )
        }

        cursor?.use { c ->
            val idxAddr = c.getColumnIndex(Telephony.Sms.ADDRESS)
            val idxBody = c.getColumnIndex(Telephony.Sms.BODY)
            val idxDate = c.getColumnIndex(Telephony.Sms.DATE)
            while (c.moveToNext()) {
                rows.add(
                    mapOf(
                        "sender" to if (idxAddr >= 0) c.getString(idxAddr) else null,
                        "body" to if (idxBody >= 0) c.getString(idxBody) else null,
                        "date_millis" to if (idxDate >= 0) c.getLong(idxDate) else null,
                    ),
                )
            }
        }
        return rows
    }

    private fun countSms(entities: List<String>): Int {
        val uri: Uri = Telephony.Sms.Inbox.CONTENT_URI
        val projection = arrayOf(Telephony.Sms._ID)

        val selection: String?
        val selectionArgs: Array<String>?
        if (entities.isNotEmpty()) {
            selection = entities.joinToString(" OR ") {
                "${Telephony.Sms.ADDRESS} LIKE ?"
            }
            selectionArgs = entities.map { "%$it%" }.toTypedArray()
        } else {
            selection = null
            selectionArgs = null
        }

        val cursor: Cursor? = contentResolver.query(
            uri,
            projection,
            selection,
            selectionArgs,
            null,
        )
        cursor?.use { c -> return c.count }
        return 0
    }
}
