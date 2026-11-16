package io.github.domanell.arcvolume;

import android.content.Context;
import android.util.Log;

import java.io.OutputStream;
import java.net.HttpURLConnection;
import java.net.URL;
import java.nio.charset.StandardCharsets;
import java.util.concurrent.ExecutorService;
import java.util.concurrent.Executors;

/**
 * Posts the confirmed soundbar level to a Home Assistant webhook.
 *
 * <p>The URL comes from the string resource {@code ha_webhook_url}, which build.sh generates
 * from the git-ignored ha-webhook.url file or the ARC_HA_WEBHOOK_URL variable. Empty means the
 * feature is off and the app makes no network call. The body is a fixed JSON shape built from
 * integers and a boolean only; no text from the TV or a user is ever put into it.
 * Only a settled level is sent, never a prediction. Failures are logged and dropped.
 */
final class HaWebhook {
    private static final String TAG = "ArcVolume";
    private static final int TIMEOUT_MS = 3000;
    private static final ExecutorService EXECUTOR = Executors.newSingleThreadExecutor();

    private final String url;
    private int lastLevel = Integer.MIN_VALUE;
    private boolean lastMuted;

    HaWebhook(Context context) {
        int id = context.getResources().getIdentifier("ha_webhook_url", "string", context.getPackageName());
        this.url = validUrl(id == 0 ? "" : context.getString(id));
        if (url != null) {
            Log.i(TAG, "HA webhook enabled");
        }
    }

    /** Returns the URL if it is a plain http(s) URL, else null (feature off). */
    static String validUrl(String raw) {
        String value = raw == null ? "" : raw.trim();
        if (value.startsWith("http://") || value.startsWith("https://")) {
            return value;
        }
        return null;
    }

    /** The fixed JSON body. Integers and a boolean only. */
    static String body(int level, int step, boolean muted, int max) {
        return "{\"level\":" + level + ",\"muted\":" + muted + ",\"step\":" + step
                + ",\"max\":" + max + ",\"source\":\"stream_music\"}";
    }

    /** Sends the settled state if it differs from the last one sent. Main thread. */
    void publish(int level, int step, boolean muted, int max) {
        if (url == null || (level == lastLevel && muted == lastMuted)) {
            return;
        }
        lastLevel = level;
        lastMuted = muted;
        final String payload = body(level, step, muted, max);
        EXECUTOR.execute(() -> post(payload));
    }

    private void post(String payload) {
        HttpURLConnection connection = null;
        try {
            connection = (HttpURLConnection) new URL(url).openConnection();
            connection.setConnectTimeout(TIMEOUT_MS);
            connection.setReadTimeout(TIMEOUT_MS);
            connection.setRequestMethod("POST");
            connection.setDoOutput(true);
            connection.setRequestProperty("Content-Type", "application/json");
            byte[] bytes = payload.getBytes(StandardCharsets.UTF_8);
            try (OutputStream out = connection.getOutputStream()) {
                out.write(bytes);
            }
            Log.i(TAG, "webhook " + payload + " -> HTTP " + connection.getResponseCode());
        } catch (Exception e) {
            Log.w(TAG, "webhook failed: " + e.getClass().getSimpleName());
        } finally {
            if (connection != null) {
                connection.disconnect();
            }
        }
    }
}
