package io.github.codemastervy.arcvolume;

/** How a control reaches the soundbar. The panel asks each transport in order. */
interface Transport {
    String name();

    /** True if this transport can really perform the control. Never claim support that is untested. */
    boolean supports(String id);

    /** Performs a supported control; id is always from ControlTable. */
    void send(String id);
}
