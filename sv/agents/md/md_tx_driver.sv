
// md_tx_driver.sv - Driver para aplicar backpressure y errores en MD TX
import tb_defs_pkg::*;

class md_tx_driver;
  virtual md_if vif;
  rand bit backpressure;
  rand bit inject_err;

  function new(virtual md_if vif, bit backpressure=1, bit inject_err=0);
    this.vif = vif;
    this.backpressure = backpressure;
    this.inject_err = inject_err;
  endfunction

  task run();
    vif.tx_drv_cb.md_tx_ready <= 1'b1;
    vif.tx_drv_cb.md_tx_err   <= 1'b0;

    forever begin
      @(vif.tx_drv_cb);
      if (backpressure) begin
        if ($urandom_range(0,7) == 0) begin
          vif.tx_drv_cb.md_tx_ready <= 1'b0;
        end else begin
          vif.tx_drv_cb.md_tx_ready <= 1'b1;
        end
      end else begin
        vif.tx_drv_cb.md_tx_ready <= 1'b1;
      end

      // Samplear nets, NO outputs del clocking block
      if (inject_err && vif.md_tx_valid && vif.md_tx_ready) begin
        vif.tx_drv_cb.md_tx_err <= ($urandom_range(0,15)==0);
      end else begin
        vif.tx_drv_cb.md_tx_err <= 1'b0;
      end
    end
  endtask
endclass
