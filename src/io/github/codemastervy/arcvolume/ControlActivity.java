package io.github.codemastervy.arcvolume;

import android.app.Activity;
import android.media.AudioManager;
import android.os.Bundle;
import android.widget.LinearLayout;
import android.widget.Toast;

/** D-pad panel for the soundbar. Each row uses the first transport that really supports it. */
public class ControlActivity extends Activity {
    private Transport[] transports;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        transports = new Transport[] {
                new CecTransport(getSystemService(AudioManager.class)), new IrHaTransport()};
        LinearLayout column = Ui.screen(this);
        Ui.add(column, Ui.title(this, "Soundbar control"), 0);
        Ui.Row first = null;
        for (ControlTable.Entry entry : ControlTable.ENTRIES) {
            Transport transport = transportFor(entry.id);
            Ui.Row row = Ui.row(this, entry.label, v -> press(entry, transport));
            row.setSummary(transport == null ? "NOT SUPPORTED over CEC" : transport.name());
            Ui.add(column, row.view, first == null ? 16 : 8);
            if (first == null) {
                first = row;
            }
        }
        first.view.requestFocus();
    }

    private Transport transportFor(String id) {
        for (Transport transport : transports) {
            if (transport.supports(id)) {
                return transport;
            }
        }
        return null;
    }

    private void press(ControlTable.Entry entry, Transport transport) {
        if (transport == null || !ControlTable.known(entry.id)) {
            Toast.makeText(this, entry.label + ": not supported over CEC", Toast.LENGTH_SHORT).show();
            return;
        }
        transport.send(entry.id);
    }
}
