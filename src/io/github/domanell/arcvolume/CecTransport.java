package io.github.domanell.arcvolume;

import android.media.AudioManager;

/**
 * Standard CEC through Android's own volume path: the TV turns these into CEC User Control volume
 * up/down/mute for the soundbar. A sideloaded app cannot send any other CEC message (HdmiControlManager
 * is privileged), so power, sound mode and subwoofer are NOT supported here. See docs/CEC.md.
 */
final class CecTransport implements Transport {
    private final AudioManager audio;

    CecTransport(AudioManager audio) {
        this.audio = audio;
    }

    @Override
    public String name() {
        return "HDMI-CEC";
    }

    @Override
    public boolean supports(String id) {
        return "vol_up".equals(id) || "vol_down".equals(id) || "mute".equals(id);
    }

    @Override
    public void send(String id) {
        int direction = "vol_up".equals(id) ? AudioManager.ADJUST_RAISE
                : "vol_down".equals(id) ? AudioManager.ADJUST_LOWER
                : AudioManager.ADJUST_TOGGLE_MUTE;
        audio.adjustStreamVolume(AudioManager.STREAM_MUSIC, direction, 0);
    }
}
