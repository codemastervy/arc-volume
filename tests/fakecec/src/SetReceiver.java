package test.fakecec;

import android.content.BroadcastReceiver;
import android.content.Context;
import android.content.Intent;
import android.media.AudioManager;

/** TEST ONLY. Plays the soundbar's <Report Audio Status>: sets STREAM_MUSIC like the TV does.
 *  am broadcast -n test.fakecec/.SetReceiver --ei level N   |  --es mute on|off */
public class SetReceiver extends BroadcastReceiver {
    @Override
    public void onReceive(Context c, Intent i) {
        AudioManager a = c.getSystemService(AudioManager.class);
        if (i.hasExtra("level")) {
            a.setStreamVolume(AudioManager.STREAM_MUSIC, i.getIntExtra("level", 0), 0);
        }
        String m = i.getStringExtra("mute");
        if (m != null) {
            a.adjustStreamVolume(AudioManager.STREAM_MUSIC,
                    "on".equals(m) ? AudioManager.ADJUST_MUTE : AudioManager.ADJUST_UNMUTE, 0);
        }
    }
}
