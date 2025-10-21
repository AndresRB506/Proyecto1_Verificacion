
// scoreboard.sv - Comparador de resultados entre el DUT y el modelo de referencia
import tb_defs_pkg::*;
`include "tb_params.vh"

class scoreboard;
  mailbox #(md_beat_t) rx_mbx;  // RX observado
  mailbox #(md_beat_t) tx_mbx;  // TX observado

  aligner_ref_model rm;         // modelo de referencia

  function new(mailbox #(md_beat_t) rx_mbx, mailbox #(md_beat_t) tx_mbx,
               int unsigned ctrl_size, int unsigned ctrl_offset, bit coalesce_mode);
    this.rx_mbx = rx_mbx; this.tx_mbx = tx_mbx;
    rm = new(ctrl_size, ctrl_offset, coalesce_mode);
  endfunction

  // Bucle principal: alimentar modelo con RX y comparar cada TX real con el esperado
  task run();
    md_beat_t rx, tx_exp, tx_act;
    bit have_exp = 0;
    forever begin
      // Extraer RX si disponible
      if (rx_mbx.try_get(rx)) begin
        rm.push_rx(rx);
      end

      // Intentar generar un esperado
      if (rm.pop_tx(tx_exp)) begin
        have_exp = 1;
      end

      // Si esperamos algo, consumir el TX del DUT y comparar
      if (have_exp) begin
        tx_mbx.get(tx_act);
        if (tx_act.size !== tx_exp.size || tx_act.offset !== tx_exp.offset || tx_act.data !== tx_exp.data) begin
          $error("SCB mismatch: exp size=%0d off=%0d data=0x%0h, got size=%0d off=%0d data=0x%0h",
                 tx_exp.size, tx_exp.offset, tx_exp.data, tx_act.size, tx_act.offset, tx_act.data);
        end
        have_exp = 0;
      end else begin
        // Si llega TX sin esperado, advertir (posible desfase de modelo)
        if (tx_mbx.try_get(tx_act)) begin
          $warning("TX inesperado: size=%0d off=%0d data=0x%0h (modelo no tenía listo)",
                   tx_act.size, tx_act.offset, tx_act.data);
        end
      end

      #1ns; // alivio de simulación
    end
  endtask
endclass
