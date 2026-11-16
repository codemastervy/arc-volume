package io.github.domanell.arcvolume;

/**
 * Placeholder for the later fallback (Home Assistant webhook -> IR blaster on the NUC). Deliberately
 * unimplemented: supports nothing, so the panel shows NOT SUPPORTED instead of pretending.
 */
final class IrHaTransport implements Transport {
    @Override
    public String name() {
        return "IR via Home Assistant";
    }

    @Override
    public boolean supports(String id) {
        return false;
    }

    @Override
    public void send(String id) {
        throw new UnsupportedOperationException("not implemented");
    }
}
