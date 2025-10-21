
// md_tx_driver.sv - Driver para aplicar backpressure y errores en MD TX
import tb_defs_pkg::*;

class md_tx_driver;
  virtual md_if vif;
  rand bit backpressure; // si es 1, estalla md_tx_ready aleatoriamente
  rand bit inject_err;   // si es 1, puede inyectar md_tx_err en handshakes

  function new(virtual md_if vif, bit backpressure=1, bit inject_err=0);
    this.vif = vif;
    this.backpressure = backpressure;
    this.inject_err = inject_err;
  endfunction

  task run();
    // ready alto por defecto
    vif.tx_drv_cb.md_tx_ready <= 1'b1;
    vif.tx_drv_cb.md_tx_err   <= 1'b0;

    forever begin
      @(vif.tx_drv_cb);
      if (backpressure) begin
        // Estallar aleatoriamente (1 de cada ~8 ciclos)
        if ($urandom_range(0,7) == 0) begin
          vif.tx_drv_cb.md_tx_ready <= 1'b0;
        end else begin
          vif.tx_drv_cb.md_tx_ready <= 1'b1;
        end
      end else begin
        vif.tx_drv_cb.md_tx_ready <= 1'b1;
      end

      // Inyectar error solo en handshake
      if (inject_err && vif.tx_drv_cb.md_tx_valid && vif.tx_drv_cb.md_tx_ready) begin
        vif.tx_drv_cb.md_tx_err <= ($urandom_range(0,15)==0);
      end else begin
        vif.tx_drv_cb.md_tx_err <= 1'b0;
      end
    end
  endtask
endclass
