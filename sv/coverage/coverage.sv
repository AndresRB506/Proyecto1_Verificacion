
// coverage.sv - Cobertura funcional RX/TX (solo en handshake)
import tb_defs_pkg::*;

class md_coverage;
  virtual md_if vif;

  covergroup cg_rx @(posedge vif.clk);
    option.per_instance = 1;
    cp_size   : coverpoint vif.rx_mon_cb.md_rx_size
               iff (vif.rx_mon_cb.md_rx_valid && vif.rx_mon_cb.md_rx_ready) {
      bins s1 = {1}; bins s2 = {2}; bins s4 = {4};
      illegal_bins zero = {0};
    }
    cp_offset : coverpoint vif.rx_mon_cb.md_rx_offset
               iff (vif.rx_mon_cb.md_rx_valid && vif.rx_mon_cb.md_rx_ready) {
      bins o0={0}; bins o1={1}; bins o2={2}; bins o3={3};
    }
    cross_size_off : cross cp_size, cp_offset
               iff (vif.rx_mon_cb.md_rx_valid && vif.rx_mon_cb.md_rx_ready);
  endgroup

  covergroup cg_tx @(posedge vif.clk);
    option.per_instance = 1;
    cp_size   : coverpoint vif.tx_mon_cb.md_tx_size
               iff (vif.tx_mon_cb.md_tx_valid && vif.tx_mon_cb.md_tx_ready) {
      bins s1 = {1}; bins s2 = {2}; bins s4 = {4};
      illegal_bins zero = {0};
    }
    cp_offset : coverpoint vif.tx_mon_cb.md_tx_offset
               iff (vif.tx_mon_cb.md_tx_valid && vif.tx_mon_cb.md_tx_ready) {
      bins o0={0}; bins o1={1}; bins o2={2}; bins o3={3};
    }
    cross_size_off : cross cp_size, cp_offset
               iff (vif.tx_mon_cb.md_tx_valid && vif.tx_mon_cb.md_tx_ready);
  endgroup

  function new(virtual md_if vif); this.vif = vif; cg_rx = new(); cg_tx = new(); endfunction
endclass
