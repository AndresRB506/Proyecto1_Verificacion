
// scoreboard.sv - Comparador DUT vs modelo
import tb_defs_pkg::*;
`include "tb_params.vh"

class scoreboard;
  mailbox #(md_beat_t) rx_mbx;
  mailbox #(md_beat_t) tx_mbx;
  aligner_ref_model rm;

  function new(mailbox #(md_beat_t) rx_mbx, mailbox #(md_beat_t) tx_mbx,
               int unsigned ctrl_size, int unsigned ctrl_offset, bit coalesce_mode);
    this.rx_mbx = rx_mbx; this.tx_mbx = tx_mbx;
    rm = new(ctrl_size, ctrl_offset, coalesce_mode);
  endfunction

  task run();
    md_beat_t rx, tx_exp, tx_act;
    bit have_exp = 0;
    forever begin
      if (rx_mbx.try_get(rx)) begin
        rm.push_rx(rx);
      end
      if (rm.pop_tx(tx_exp)) have_exp = 1;

      if (have_exp) begin
        tx_mbx.get(tx_act);
        if (tx_act.size !== tx_exp.size || tx_act.offset !== tx_exp.offset || tx_act.data !== tx_exp.data) begin
          $error("SCB mismatch: exp size=%0d off=%0d data=0x%0h, got size=%0d off=%0d data=0x%0h",
                 tx_exp.size, tx_exp.offset, tx_exp.data, tx_act.size, tx_act.offset, tx_act.data);
        end
        have_exp = 0;
      end else begin
        if (tx_mbx.try_get(tx_act)) begin
          $warning("TX inesperado: size=%0d off=%0d data=0x%0h (modelo no tenía listo)",
                   tx_act.size, tx_act.offset, tx_act.data);
        end
      end
      #1ns;
    end
  endtask
endclass
