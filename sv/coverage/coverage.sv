
// coverage.sv - Cobertura funcional para tamaños/offsets y TX resultante
import tb_defs_pkg::*;

class md_coverage;
  virtual md_if vif;

  // Cobertura en RX (tamaños 1/2/4 y offsets típicos para BUS_BYTES=4)
  covergroup cg_rx @(posedge vif.clk);
    option.per_instance = 1;
    cp_size   : coverpoint vif.rx_mon_cb.md_rx_size {
      bins s1 = {1}; bins s2 = {2}; bins s4 = {4};
      illegal_bins zero = {0};
    }
    cp_offset : coverpoint vif.rx_mon_cb.md_rx_offset {
      bins o0={0}; bins o1={1}; bins o2={2}; bins o3={3};
    }
    cross_size_off : cross cp_size, cp_offset;
  endgroup

  // Cobertura en TX (verificar alineamiento y tamaños emitidos)
  covergroup cg_tx @(posedge vif.clk);
    option.per_instance = 1;
    cp_size   : coverpoint vif.tx_mon_cb.md_tx_size {
      bins s1 = {1}; bins s2 = {2}; bins s4 = {4};
      illegal_bins zero = {0};
    }
    cp_offset : coverpoint vif.tx_mon_cb.md_tx_offset {
      bins o0={0}; bins o1={1}; bins o2={2}; bins o3={3};
    }
    cross_size_off : cross cp_size, cp_offset;
  endgroup

  function new(virtual md_if vif); this.vif = vif; cg_rx = new(); cg_tx = new(); endfunction
endclass
