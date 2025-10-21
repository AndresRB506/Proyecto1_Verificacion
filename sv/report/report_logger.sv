
// report_logger.sv - Generador de reporte CSV de RX/TX + contadores por APB
import tb_defs_pkg::*;

class report_logger;
  virtual apb_if apb_vif;
  apb_driver      apb_drv;
  mailbox #(md_beat_t) rx_mbx;
  mailbox #(md_beat_t) tx_mbx;
  integer          fh;

  localparam STATUS_ADDR = 16'h000C;
  localparam IRQEN_ADDR  = 16'h00F0;
  localparam IRQ_ADDR    = 16'h00F4;

  function new(virtual apb_if apb_vif,
               apb_driver apb_drv,
               mailbox #(md_beat_t) rx_mbx,
               mailbox #(md_beat_t) tx_mbx,
               string filename="aligner_report.csv");
    this.apb_vif = apb_vif;
    this.apb_drv = apb_drv;
    this.rx_mbx  = rx_mbx;
    this.tx_mbx  = tx_mbx;
    fh = $fopen(filename, "w");
    if (fh == 0) $fatal("No se pudo abrir el archivo CSV: %s", filename);
    $fwrite(fh, "time_ps,dir,size,offset,data_hex,CNT_DROP,RX_LVL,TX_LVL,IRQEN_hex,IRQ_hex\n");
  endfunction

  function void decode_status(input logic [31:0] status,
                              output int unsigned cnt_drop,
                              output int unsigned rx_lvl,
                              output int unsigned tx_lvl);
    cnt_drop = status[7:0];
    rx_lvl   = status[11:8];
    tx_lvl   = status[19:16];
  endfunction

  task run();
    md_beat_t rx, tx;
    logic [31:0] rdata;
    logic pslverr;
    int unsigned cnt_drop, rx_lvl, tx_lvl;
    logic [31:0] irqen, irq;

    forever begin
      if (rx_mbx.try_get(rx)) begin
        apb_drv.read(STATUS_ADDR, rdata, 0, pslverr); decode_status(rdata, cnt_drop, rx_lvl, tx_lvl);
        apb_drv.read(IRQEN_ADDR,  rdata, 0, pslverr); irqen = rdata;
        apb_drv.read(IRQ_ADDR,    rdata, 0, pslverr); irq   = rdata;
        $fwrite(fh, "%0t,RX,%0d,%0d,0x%0h,%0d,%0d,%0d,0x%08h,0x%08h\n",
                     $time, rx.size, rx.offset, rx.data, cnt_drop, rx_lvl, tx_lvl, irqen, irq);
      end else if (tx_mbx.try_get(tx)) begin
        apb_drv.read(STATUS_ADDR, rdata, 0, pslverr); decode_status(rdata, cnt_drop, rx_lvl, tx_lvl);
        apb_drv.read(IRQEN_ADDR,  rdata, 0, pslverr); irqen = rdata;
        apb_drv.read(IRQ_ADDR,    rdata, 0, pslverr); irq   = rdata;
        $fwrite(fh, "%0t,TX,%0d,%0d,0x%0h,%0d,%0d,%0d,0x%08h,0x%08h\n",
                     $time, tx.size, tx.offset, tx.data, cnt_drop, rx_lvl, tx_lvl, irqen, irq);
      end else begin
        @(posedge apb_vif.pclk);
      end
    end
  endtask
endclass
