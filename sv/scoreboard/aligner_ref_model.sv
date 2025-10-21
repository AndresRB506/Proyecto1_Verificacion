
// aligner_ref_model.sv - Modelo de referencia para la alineación
import tb_defs_pkg::*;

class aligner_ref_model;
  int unsigned ctrl_size   = 1; // bytes
  int unsigned ctrl_offset = 0; // bytes
  bit          coalesce_mode = 0; // 0: fijo, 1: coalesce

  byte window[$];

  function new(int unsigned size=1, int unsigned offset=0, bit coalesce_mode=0);
    this.ctrl_size     = size;
    this.ctrl_offset   = offset;
    this.coalesce_mode = coalesce_mode;
  endfunction

  function void push_rx(md_beat_t rx);
    byte bytes[BUS_BYTES];
    int i,j;
    for (i=0; i<BUS_BYTES; i++) begin
      bytes[i] = rx.data >> (8*i);
    end
    for (j=0; j<rx.size; j++) begin
      window.push_back(bytes[rx.offset + j]);
    end
  endfunction

  function bit pop_tx(output md_beat_t tx);
    int target_size;
    int sz, k;
    logic [ALGN_DATA_WIDTH-1:0] word;

    if (coalesce_mode) begin
      target_size = -1;
      for (sz = BUS_BYTES; sz >= 1; sz--) begin
        if (md_legal_combination(ctrl_offset, sz) && (window.size() >= sz)) begin
          target_size = sz; break; end
      end
      if (target_size == -1) return 0;
    end else begin
      target_size = ctrl_size;
      if (!md_legal_combination(ctrl_offset, target_size)) return 0;
      if (window.size() < target_size) return 0;
    end

    tx.valid  = 1'b1;
    tx.offset = ctrl_offset[OFFSET_W-1:0];
    tx.size   = target_size[SIZE_W-1:0];

    word = '0;
    for (k=0; k<target_size; k++) begin
      word[(8*(ctrl_offset+k)) +: 8] = window[k];
    end
    tx.data = word;

    for (k=0; k<target_size; k++) begin
      window.pop_front();
    end
    return 1;
  endfunction
endclass
