package com.autimate.autimate

import android.app.PendingIntent
import android.appwidget.AppWidgetManager
import android.appwidget.AppWidgetProvider
import android.content.Context
import android.content.Intent
import android.net.Uri
import android.widget.RemoteViews
import es.antonborri.home_widget.HomeWidgetLaunchIntent
import es.antonborri.home_widget.HomeWidgetPlugin

/**
 * Home-screen widget showing up to four urgent phrases.
 *
 * A tap opens the app on `autimate://phrase?id=...`, which the Dart side
 * resolves and speaks. It intentionally does not try to speak from the
 * widget process: text-to-speech there would need its own engine lifecycle,
 * would not honour the app's sensory-mode volume settings, and would be a
 * second speech path to keep in step with the first.
 *
 * NOT YET VERIFIED ON A DEVICE. Written against the home_widget plugin API;
 * this machine has no Android SDK, so it has never been compiled or run.
 */
class QuickPhraseWidgetProvider : AppWidgetProvider() {

    override fun onUpdate(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetIds: IntArray
    ) {
        val data = HomeWidgetPlugin.getData(context)
        val count = data.getInt("phrase_count", 0)

        for (widgetId in appWidgetIds) {
            val views = RemoteViews(context.packageName, R.layout.quick_phrase_widget)
            val slots = intArrayOf(
                R.id.phrase_0,
                R.id.phrase_1,
                R.id.phrase_2,
                R.id.phrase_3
            )

            for (index in slots.indices) {
                val label = data.getString("phrase_${index}_label", "") ?: ""
                val phraseId = data.getString("phrase_${index}_id", "") ?: ""
                val viewId = slots[index]

                if (index >= count || label.isEmpty()) {
                    // An empty slot is hidden rather than left blank: four
                    // buttons where two are dead is a worse target field
                    // than two buttons.
                    views.setViewVisibility(viewId, android.view.View.GONE)
                    continue
                }

                views.setViewVisibility(viewId, android.view.View.VISIBLE)
                views.setTextViewText(viewId, label)
                views.setOnClickPendingIntent(
                    viewId,
                    launchIntent(context, phraseId)
                )
            }

            appWidgetManager.updateAppWidget(widgetId, views)
        }
    }

    /**
     * Opens the app with the phrase id attached.
     *
     * A distinct request code per phrase, because PendingIntents with the
     * same code and no distinguishing extras get collapsed by the system —
     * which would make every button speak whichever phrase was registered
     * last.
     */
    private fun launchIntent(context: Context, phraseId: String): PendingIntent {
        val uri = Uri.parse("autimate://phrase?id=$phraseId")
        return HomeWidgetLaunchIntent.getActivity(
            context,
            MainActivity::class.java,
            uri
        )
    }

    override fun onEnabled(context: Context) {
        // Nothing to do. The Dart side pushes data whenever the phrase bank
        // changes, so there is no polling and updatePeriodMillis is zero.
    }

    override fun onDisabled(context: Context) {
        // Data lives in shared preferences owned by the plugin and is
        // cleared by the app when the active child changes; removing the
        // widget should not clear it, because the caregiver may add the
        // widget back.
    }
}
