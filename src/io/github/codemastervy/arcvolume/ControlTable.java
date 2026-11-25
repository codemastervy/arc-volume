package io.github.codemastervy.arcvolume;

/** The fixed list of soundbar controls. Only ids from this table are ever sent to a transport. */
final class ControlTable {
    static final class Entry {
        final String id;
        final String label;

        Entry(String id, String label) {
            this.id = id;
            this.label = label;
        }
    }

    static final Entry[] ENTRIES = {
            new Entry("vol_up", "Volume up"),
            new Entry("vol_down", "Volume down"),
            new Entry("mute", "Mute"),
            new Entry("power", "Soundbar power"),
            new Entry("sound_mode", "Sound mode"),
            new Entry("woofer_up", "Subwoofer +"),
            new Entry("woofer_down", "Subwoofer −"),
    };

    private ControlTable() {
    }

    static boolean known(String id) {
        for (Entry entry : ENTRIES) {
            if (entry.id.equals(id)) {
                return true;
            }
        }
        return false;
    }
}
