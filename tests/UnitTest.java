package io.github.domanell.arcvolume;

/** Host-JVM tests for the pure logic. Run via tests/run.sh. */
public class UnitTest {
    static int fails;
    static void eq(Object a, Object b, String what) {
        if (!java.util.Objects.equals(a, b)) { fails++; System.out.println("FAIL " + what + ": got " + a + " want " + b); }
        else System.out.println("ok   " + what);
    }
    public static void main(String[] x) {
        // step-1 bar: every change shown as is
        VolumePredictor p = new VolumePredictor(5, VolumePredictor.UNKNOWN, false, true, 0, 30);
        eq(p.onIndex(6), 6, "step1 shows 6");
        // learn step 2 from two isolated presses (local +1, report +2)
        p = new VolumePredictor(4, VolumePredictor.UNKNOWN, false, true, 0, 30);
        for (int base = 4, i = 0; i < 2; i++, base += 2) {
            p.onIndex(base + 1); p.onIndex(base + 2);
            p.settle(base + 2, true);
        }
        eq(p.step(), 2, "learns step 2");
        eq(p.determined(), true, "step determined");
        // known step 2: odd index is the local intermediate -> predicted next level shown
        p.configure(2, true, false);
        eq(p.onIndex(9), 10, "intermediate 9 shown as 10 (confirmed 8)");
        p.settle(10, false);
        // clamp to max
        p = new VolumePredictor(28, 2, true, false, 0, 29);
        eq(p.onIndex(29), 29, "clamped to max");
        // manual step never replaced
        p = new VolumePredictor(4, 3, true, false, 0, 30);
        for (int i = 0, b = 4; i < 6; i++) { p.onIndex(b + 1); p.onIndex(b + 2); p.settle(b + 2, true); b += 2; }
        eq(p.step(), 3, "manual step kept");
        System.exit(fails == 0 ? 0 : 1);
    }
}
