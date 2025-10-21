
// top_tb.sv - Testbench no-UVM en capas para el Aligner
`timescale 1ns/1ps
import tb_defs_pkg::*;

module top_tb;
  localparam int ALGN_DATA_WIDTH = tb_defs_pkg::ALGN_DATA_WIDTH;
  localparam int BUS_BYTES       = (ALGN_DATA_WIDTH/8);
  localparam int OFFSET_W        = (BUS_BYTES>1)?$clog2(BUS_BYTES):1;
  localparam int SIZE_W          = $clog2(BUS_BYTES)+1;

  logic clk, reset_n;
  logic pclk, preset_n;
  initial begin clk=0; forever #5 clk=~clk; end
  initial begin pclk=0; forever #5 pclk=~pclk; end
  initial begin reset_n=0; preset_n=0; repeat (5) @(posedge clk); reset_n=1; preset_n=1; end

  apb_if apb(pclk, preset_n);
  md_if  #(.ALGN_DATA_WIDTH(ALGN_DATA_WIDTH)) md(clk, reset_n);

  // Señal de interrupción y variables de módulo
  wire irq;
  logic pslverr;
  logic [31:0] rdata;
  mailbox #(apb_txn_t) apb_mbx;

  // DUT
  cfs_aligner #(
    .ALGN_DATA_WIDTH(ALGN_DATA_WIDTH),
    .FIFO_DEPTH     (8)
  ) u_dut (
    .clk       (clk),
    .reset_n   (reset_n),
    .paddr     (apb.paddr), .pwrite(apb.pwrite), .psel(apb.psel), .penable(apb.penable),
    .pwdata    (apb.pwdata), .pready(apb.pready), .prdata(apb.prdata), .pslverr(apb.pslverr),
    .md_rx_valid(md.md_rx_valid), .md_rx_data(md.md_rx_data), .md_rx_offset(md.md_rx_offset), .md_rx_size(md.md_rx_size),
    .md_rx_ready(md.md_rx_ready), .md_rx_err(md.md_rx_err),
    .md_tx_valid(md.md_tx_valid), .md_tx_data(md.md_tx_data), .md_tx_offset(md.md_tx_offset), .md_tx_size(md.md_tx_size),
    .md_tx_ready(md.md_tx_ready), .md_tx_err(md.md_tx_err),
    .irq(irq)
  );

  // Assertions
  md_assertions #(.ALGN_DATA_WIDTH(ALGN_DATA_WIDTH)) u_md_assert (
    .clk(clk), .reset_n(reset_n),
    .md_rx_valid(md.md_rx_valid), .md_rx_data(md.md_rx_data), .md_rx_offset(md.md_rx_offset), .md_rx_size(md.md_rx_size), .md_rx_ready(md.md_rx_ready), .md_rx_err(md.md_rx_err),
    .md_tx_valid(md.md_tx_valid), .md_tx_data(md.md_tx_data), .md_tx_offset(md.md_tx_offset), .md_tx_size(md.md_tx_size), .md_tx_ready(md.md_tx_ready)
  );
  apb_assertions u_apb_assert(apb);

  // Mailboxes TB
  mailbox #(md_beat_t) rx2scb = new();
  mailbox #(md_beat_t) tx2scb = new();

  // Componentes TB
  apb_driver   apb_drv;
  apb_monitor  apb_mon;
  md_rx_driver rx_drv;
  md_tx_driver tx_drv;
  md_rx_monitor rx_mon;
  md_tx_monitor tx_mon;
  scoreboard   scb;
  md_coverage  cov;

  initial begin
    tb_cfg cfg = new();
    cfg.num_rx_beats      = 300;
    cfg.max_wait_states   = 3;
    cfg.inject_illegal_md = 1;
    cfg.tx_backpressure   = 1;
    cfg.tx_inject_err     = 0;
    cfg.coalesce_mode     = 0; // *** fijo por CTRL.SIZE ***

    apb_drv = new(apb, cfg.max_wait_states);
    apb_mbx = new();
    apb_mon = new(apb, apb_mbx);
    rx_drv  = new(md, cfg.num_rx_beats, cfg.inject_illegal_md);
    tx_drv  = new(md, cfg.tx_backpressure, cfg.tx_inject_err);
    rx_mon  = new(md, rx2scb);
    tx_mon  = new(md, tx2scb);
    scb     = new(rx2scb, tx2scb, /*ctrl_size*/ 1, /*ctrl_offset*/ 0, cfg.coalesce_mode);
    cov     = new(md);

    // Logger CSV
    report_logger rep = new(apb, apb_drv, rx2scb, tx2scb, "aligner_report.csv");

    // Reset de interfaces
    apb.reset_apb();
    md.reset_md();

    // Programación inicial por APB
    apb_drv.write(16'h0000, 32'h0000_0001, 0, pslverr); // CTRL: SIZE=1, OFFSET=0
    if (pslverr) $fatal("Error APB inesperado en CTRL");
    apb_drv.write(16'h00F0, 32'h0000_001F, 0, pslverr); // habilitar IRQEN

    fork
      apb_drv.reset_phase();
      rx_drv.run();
      tx_drv.run();
      rx_mon.run();
      tx_mon.run();
      scb.run();
      rep.run();
    join_none

    repeat (5000) @(posedge clk);
    $display("Cobertura MD RX: %0.2f%%", cov.cg_rx.get_inst_coverage());
    $display("Cobertura MD TX: %0.2f%%", cov.cg_tx.get_inst_coverage());
    $finish;
  end
endmodule
