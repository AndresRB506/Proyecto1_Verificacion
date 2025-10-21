
// md_rx_driver.sv - Driver RX para generar estímulos MD (aleatorizado controlado)
import tb_defs_pkg::*;

class md_rx_driver;
  virtual md_if vif;
  rand int unsigned num_beats;
  rand bit inject_illegal;

  constraint c_legal_counts { num_beats inside {[1:10000]}; }

  function new(virtual md_if vif, int unsigned num_beats=200, bit inject_illegal=0);
    this.vif = vif;
    this.num_beats = num_beats;
    this.inject_illegal = inject_illegal;
  endfunction

  function void gen_beat(output md_beat_t b);
    int unsigned sz, of;
    if (!inject_illegal || ($urandom_range(0,9) != 0)) begin
      do sz = $urandom_range(1, BUS_BYTES); while (sz==0);
      do of = $urandom_range(0, BUS_BYTES-1); while (((BUS_BYTES + of) % sz) != 0);
    end else begin
      sz = $urandom_range(1, BUS_BYTES);
      of = (sz == 1) ? 1 : ($urandom_range(0, BUS_BYTES-1));
      if (((BUS_BYTES + of) % sz) == 0) of = (of+1)%BUS_BYTES;
    end
    b.valid  = 1'b1;
    b.size   = sz[SIZE_W-1:0];
    b.offset = of[OFFSET_W-1:0];
    b.data   = $urandom();
  endfunction

  task run();
    md_beat_t beat;
    vif.rx_drv_cb.md_rx_valid <= 1'b0;
    for (int i=0;i<num_beats;i++) begin
      gen_beat(beat);
      @(vif.rx_drv_cb);
      vif.rx_drv_cb.md_rx_valid  <= 1'b1;
      vif.rx_drv_cb.md_rx_data   <= beat.data;
      vif.rx_drv_cb.md_rx_offset <= beat.offset;
      vif.rx_drv_cb.md_rx_size   <= beat.size;
      do @(vif.rx_drv_cb); while (!vif.rx_drv_cb.md_rx_ready);
      @(vif.rx_drv_cb);
      vif.rx_drv_cb.md_rx_valid <= 1'b0;
    end
  endtask
endclass
