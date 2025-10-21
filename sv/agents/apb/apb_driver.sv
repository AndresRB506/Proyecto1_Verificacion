
// apb_driver.sv - Driver APB simple (sin UVM)
`include "tb_params.vh"
import tb_defs_pkg::*;

class apb_driver;
  virtual apb_if vif;
  rand int unsigned max_wait_states;

  function new(virtual apb_if vif, int unsigned max_ws=3);
    this.vif = vif;
    this.max_wait_states = max_ws;
  endfunction

  task reset_phase();
    vif.reset_apb();
    @(posedge vif.pclk);
  endtask

  task automatic write(input logic [15:0] addr, input logic [31:0] wdata, input int unsigned ws=0,
                       output logic pslverr);
    if (ws>5) ws = 5;
    @(vif.drv_cb);
    vif.drv_cb.paddr   <= addr & 16'hFFFC;
    vif.drv_cb.pwdata  <= wdata;
    vif.drv_cb.pwrite  <= 1'b1;
    vif.drv_cb.psel    <= 1'b1;
    vif.drv_cb.penable <= 1'b0;

    @(vif.drv_cb);
    vif.drv_cb.penable <= 1'b1;

    repeat (ws) @(vif.drv_cb);

    do @(vif.drv_cb); while (!vif.drv_cb.pready);
    pslverr = vif.drv_cb.pslverr;

    @(vif.drv_cb);
    vif.drv_cb.psel    <= 1'b0;
    vif.drv_cb.penable <= 1'b0;
    vif.drv_cb.pwrite  <= 1'b0;
  endtask

  task automatic read(input logic [15:0] addr, output logic [31:0] rdata, input int unsigned ws=0,
                      output logic pslverr);
    if (ws>5) ws = 5;
    @(vif.drv_cb);
    vif.drv_cb.paddr   <= addr & 16'hFFFC;
    vif.drv_cb.pwrite  <= 1'b0;
    vif.drv_cb.psel    <= 1'b1;
    vif.drv_cb.penable <= 1'b0;

    @(vif.drv_cb);
    vif.drv_cb.penable <= 1'b1;

    repeat (ws) @(vif.drv_cb);

    do @(vif.drv_cb); while (!vif.drv_cb.pready);
    rdata   = vif.drv_cb.prdata;
    pslverr = vif.drv_cb.pslverr;

    @(vif.drv_cb);
    vif.drv_cb.psel    <= 1'b0;
    vif.drv_cb.penable <= 1'b0;
  endtask
endclass
