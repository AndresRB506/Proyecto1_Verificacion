
// aligner_ref_model.sv - Modelo de referencia para la alineación (nivel transacción)
import tb_defs_pkg::*;

class aligner_ref_model;
  // Campos que reflejan CTRL.SIZE y CTRL.OFFSET del DUT
  int unsigned ctrl_size   = 1; // en bytes; 1..BUS_BYTES
  int unsigned ctrl_offset = 0; // en bytes; 0..BUS_BYTES-1
  bit          coalesce_mode = 1; // 1: coalescer hasta BUS_BYTES; 0: tamaño fijo

  // Búfer de bytes (ventana)
  byte window[$];

  function new(int unsigned size=1, int unsigned offset=0, bit coalesce_mode=1);
    this.ctrl_size     = size;
    this.ctrl_offset   = offset;
    this.coalesce_mode = coalesce_mode;
  endfunction

  // Recibir un beat RX: desempaquetar los 'size' bytes desde 'offset'
  function void push_rx(md_beat_t rx);
    byte bytes[BUS_BYTES];
    // Conversión palabra -> bytes en little-endian (byte 0 = LSB)
    for (int i=0; i<BUS_BYTES; i++) begin
      bytes[i] = rx.data >> (8*i);
    end
    for (int j=0; j<rx.size; j++) begin
      window.push_back(bytes[rx.offset + j]);
    end
  endfunction

  // Intentar producir un beat TX; devuelve 1 si se generó
  function bit pop_tx(output md_beat_t tx);
    int target_size;

    if (coalesce_mode) begin
      // Emitir el mayor tamaño legal que quepa y alinee con ctrl_offset
      target_size = -1;
      for (int sz = BUS_BYTES; sz >= 1; sz--) begin
        if (md_legal_combination(ctrl_offset, sz) && (window.size() >= sz)) begin
          target_size = sz;
          break;
        end
      end
      if (target_size == -1) return 0;
    end else begin
      target_size = ctrl_size;
      if (!md_legal_combination(ctrl_offset, target_size)) return 0;
      if (window.size() < target_size) return 0;
    end

    // Rellenar el beat TX a partir de la ventana, alineado a ctrl_offset
    tx.valid  = 1'b1;
    tx.offset = ctrl_offset[OFFSET_W-1:0];
    tx.size   = target_size[SIZE_W-1:0];

    logic [ALGN_DATA_WIDTH-1:0] word = '0;
    for (int k=0; k<target_size; k++) begin
      word[(8*(ctrl_offset+k)) +: 8] = window[k];
    end
    tx.data = word;

    // Consumir los bytes utilizados
    for (int k=0; k<target_size; k++) begin
      window.pop_front();
    end
    return 1;
  endfunction
endclass
