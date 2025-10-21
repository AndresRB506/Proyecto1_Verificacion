
// apb_monitor.sv - Monitor de transferencias APB (sin UVM)
import tb_defs_pkg::*;

class apb_monitor;
  virtual apb_if vif;
  mailbox #(apb_txn_t) mon2scb;

  function new(virtual apb_if vif, mailbox #(apb_txn_t) mon2scb);
    this.vif = vif;
    this.mon2scb = mon2scb;
  endfunction

  task run();
    apb_txn_t t;
    forever begin
      @(vif.mon_cb);
      if (vif.mon_cb.psel && vif.mon_cb.penable && vif.mon_cb.pready) begin
        t.addr = vif.mon_cb.paddr;
        t.wdata = vif.mon_cb.pwdata;
        t.cmd = (vif.mon_cb.pwrite) ? APB_WRITE : APB_READ;
        t.wait_states = '0;
        mon2scb.put(t);
      end
    end
  endtask
endclass
