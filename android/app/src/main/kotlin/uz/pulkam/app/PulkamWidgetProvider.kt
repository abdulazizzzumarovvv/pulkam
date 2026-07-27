package uz.pulkam.app

import android.app.PendingIntent
import android.appwidget.AppWidgetManager
import android.appwidget.AppWidgetProvider
import android.content.Context
import android.content.Intent
import android.graphics.Color
import android.net.Uri
import android.widget.RemoteViews
import es.antonborri.home_widget.HomeWidgetLaunchIntent
import es.antonborri.home_widget.HomeWidgetPlugin

/**
 * PulKam home-screen widget.
 * Ma'lumotlar (balans, tema rangi, isPro) Flutter tomonidan HomeWidget orqali
 * yoziladi va bu yerda o'qiladi.
 */
class PulkamWidgetProvider : AppWidgetProvider() {

    override fun onUpdate(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetIds: IntArray
    ) {
        for (widgetId in appWidgetIds) {
          try {
            val prefs = HomeWidgetPlugin.getData(context)
            val views = RemoteViews(context.packageName, R.layout.pulkam_widget)

            // ── Ma'lumotlar ───────────────────────────────────────────
            val balance = prefs.getString("balance", "0") ?: "0"
            val balanceLabel = prefs.getString("balanceLabel", "Umumiy balans") ?: "Umumiy balans"
            val currency = prefs.getString("currency", "UZS") ?: "UZS"
            val themeColor = prefs.getString("themeColor", "#13111F") ?: "#13111F"
            val isPro = prefs.getBoolean("isPro", false)

            views.setTextViewText(R.id.widget_balance_value, balance)
            views.setTextViewText(R.id.widget_balance_label, balanceLabel)
            views.setTextViewText(R.id.widget_currency, currency)

            // Asosiy fon — ilova mavzu rangida (yumaloq shaklni saqlab).
            // API 31+ da setBackgroundTintList ishlaydi; eskilarda tema
            // rangi berilmaydi (widget_bg dagi to'q rang qoladi).
            if (android.os.Build.VERSION.SDK_INT >= 31) {
                try {
                    val col = Color.parseColor(themeColor)
                    views.setColorStateList(
                        R.id.widget_root,
                        "setBackgroundTintList",
                        android.content.res.ColorStateList.valueOf(col)
                    )
                } catch (_: Exception) {}
            }

            // Ovoz (mikrofon): faqat Pro'da ko'rinadi. Fon oltin gradient
            // (floating tugma uslubi), ikonка oq — shuning uchun colorFilter yo'q.
            views.setViewVisibility(
                R.id.widget_voice,
                if (isPro) android.view.View.VISIBLE else android.view.View.GONE
            )

            // ── Kliklar (deep link orqali ilovani ochadi) ─────────────
            views.setOnClickPendingIntent(
                R.id.widget_balance_row,
                launchIntent(context, "pulkam://widget/home")
            )
            views.setOnClickPendingIntent(
                R.id.widget_kirim,
                launchIntent(context, "pulkam://widget/kirim")
            )
            views.setOnClickPendingIntent(
                R.id.widget_chiqim,
                launchIntent(context, "pulkam://widget/chiqim")
            )
            views.setOnClickPendingIntent(
                R.id.widget_voice,
                launchIntent(context, if (isPro) "pulkam://widget/voice" else "pulkam://widget/pro")
            )

            appWidgetManager.updateAppWidget(widgetId, views)
          } catch (e: Exception) {
            // Har qanday xatoda ham widget qo'shilaversin — bo'sh layout
            try {
                val fallback = RemoteViews(context.packageName, R.layout.pulkam_widget)
                appWidgetManager.updateAppWidget(widgetId, fallback)
            } catch (_: Exception) {}
          }
        }
    }

    private fun launchIntent(context: Context, uri: String): PendingIntent {
        return HomeWidgetLaunchIntent.getActivity(
            context,
            MainActivity::class.java,
            Uri.parse(uri)
        )
    }
}
