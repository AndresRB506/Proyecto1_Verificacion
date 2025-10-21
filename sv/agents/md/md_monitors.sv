
// md_monitors.sv - Monitores RX y TX para el protocolo MD (sin UVM)
import tb_defs_pkg::*;

class md_rx_monitor;
  virtual md_if vif;
  mailbox #(md_beat_t) rx2scb;

  function new(virtual md_if vif, mailbox #(md_beat_t) rx2scb);
    this.vif    = vif;
    this.rx2scb = rx2scb;
  endfunction

  task run();
    md_beat_t t;
    forever begin
      @(vif.rx_mon_cb);
      if (vif.rx_mon_cb.md_rx_valid && vif.rx_mon_cb.md_rx_ready) begin
        t.valid  = 1'b1;
        t.data   = vif.rx_mon_cb.md_rx_data;
        t.offset = vif.rx_mon_cb.md_rx_offset;
        t.size   = vif.rx_mon_cb.md_rx_size;
        rx2scb.put(t);
      end
    end
  endtask
endclass

class md_tx_monitor;
  virtual md_if vif;
  mailbox #(md_beat_t) tx2scb;

  function new(virtual md_if vif, mailbox #(md_beat_t) tx2scb);
    this.vif    = vif;
    this.tx2scb = tx2scb;
  endfunction

  task run();
    md_beat_t t;
    forever begin
      @(vif.tx_mon_cb);
      if (vif.tx_mon_cb.md_tx_valid && vif.tx_mon_cb.md_tx_ready) begin
        t.valid  = 1'b1;
        t.data   = vif.tx_mon_cb.md_tx_data;
        t.offset = vif.tx_mon_cb.md_tx_offset;
        t.size   = vif.tx_mon_cb.md_tx_size;
        tx2scb.put(t);
      end
    end
  endtask
endclass
