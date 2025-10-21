
// md_if.sv - Interfaz del protocolo MD (RX/TX) usada por el TB
`include "tb_params.vh"
interface md_if #(parameter int ALGN_DATA_WIDTH = 32,
                  parameter int BUS_BYTES = (ALGN_DATA_WIDTH/8),
                  parameter int OFFSET_W = (BUS_BYTES>1)?$clog2(BUS_BYTES):1,
                  parameter int SIZE_W   = $clog2(BUS_BYTES)+1)
                 (input logic clk, input logic reset_n);
  // RX hacia el DUT
  logic                       md_rx_valid;
  logic [ALGN_DATA_WIDTH-1:0] md_rx_data;
  logic [OFFSET_W-1:0]        md_rx_offset;
  logic [SIZE_W-1:0]          md_rx_size;
  logic                       md_rx_ready; // del DUT
  logic                       md_rx_err;   // del DUT

  // TX desde el DUT
  logic                       md_tx_valid;
  logic [ALGN_DATA_WIDTH-1:0] md_tx_data;
  logic [OFFSET_W-1:0]        md_tx_offset;
  logic [SIZE_W-1:0]          md_tx_size;
  logic                       md_tx_ready; // hacia el DUT
  logic                       md_tx_err;   // hacia el DUT

  clocking rx_drv_cb @(posedge clk);
    output md_rx_valid, md_rx_data, md_rx_offset, md_rx_size;
    input  md_rx_ready, md_rx_err;
  endclocking

  clocking rx_mon_cb @(posedge clk);
    input md_rx_valid, md_rx_data, md_rx_offset, md_rx_size, md_rx_ready, md_rx_err;
  endclocking

  clocking tx_drv_cb @(posedge clk);
    output md_tx_ready, md_tx_err;
    input  md_tx_valid, md_tx_data, md_tx_offset, md_tx_size;
  endclocking

  clocking tx_mon_cb @(posedge clk);
    input md_tx_valid, md_tx_data, md_tx_offset, md_tx_size, md_tx_ready;
  endclocking

  task automatic reset_md();
    rx_drv_cb.md_rx_valid <= 1'b0;
    rx_drv_cb.md_rx_data  <= '0;
    rx_drv_cb.md_rx_offset<= '0;
    rx_drv_cb.md_rx_size  <= '0;
    tx_drv_cb.md_tx_ready <= 1'b1;
    tx_drv_cb.md_tx_err   <= 1'b0;
  endtask
endinterface
