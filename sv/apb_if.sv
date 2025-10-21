
// apb_if.sv - Interfaz AMBA3 APB para el testbench
interface apb_if(input logic pclk, input logic preset_n);
  logic        psel;
  logic        penable;
  logic        pwrite;
  logic [15:0] paddr;
  logic [31:0] pwdata;
  logic [31:0] prdata;
  logic        pready;
  logic        pslverr;

  clocking drv_cb @(posedge pclk);
    output psel, penable, pwrite, paddr, pwdata;
    input  prdata, pready, pslverr;
  endclocking

  clocking mon_cb @(posedge pclk);
    input psel, penable, pwrite, paddr, pwdata, prdata, pready, pslverr;
  endclocking

  task automatic reset_apb();
    drv_cb.psel    <= 1'b0;
    drv_cb.penable <= 1'b0;
    drv_cb.pwrite  <= 1'b0;
    drv_cb.paddr   <= '0;
    drv_cb.pwdata  <= '0;
  endtask
endinterface
