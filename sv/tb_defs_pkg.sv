
// tb_defs_pkg.sv
// ----------------------------------------------------------------------------
// Paquete de definiciones para el testbench (NO UVM)
// Contiene parámetros comunes, tipos de transacción y utilidades.
// ----------------------------------------------------------------------------
package tb_defs_pkg;
  parameter int ALGN_DATA_WIDTH = 32; // bits del bus de datos MD
  parameter int BUS_BYTES       = (ALGN_DATA_WIDTH/8);
  parameter int FIFO_DEPTH      = 8;

  function int clog2(input int v);
    int i; for(i=0; 2**i < v; i++); return i; endfunction
  localparam int OFFSET_W = (BUS_BYTES > 1) ? clog2(BUS_BYTES) : 1; // max(1, log2(BUS_BYTES))
  localparam int SIZE_W   = clog2(BUS_BYTES) + 1;                   // log2(BUS_BYTES)+1

  typedef enum logic [1:0] {APB_READ=2'b00, APB_WRITE=2'b01} apb_cmd_e;

  typedef struct packed {
    logic [15:0]   addr;   // Alineada a palabra (addr[1:0] ignorados)
    logic [31:0]   wdata;
    apb_cmd_e      cmd;
    int unsigned   wait_states; // 0..5
  } apb_txn_t;

  typedef struct packed {
    logic                      valid;
    logic [ALGN_DATA_WIDTH-1:0] data;
    logic [OFFSET_W-1:0]        offset; // bytes
    logic [SIZE_W-1:0]          size;   // bytes (0 ilegal)
  } md_beat_t;

  function bit md_legal_combination(input int unsigned offset, input int unsigned size);
    if (size == 0) return 0;
    return (((BUS_BYTES + offset) % size) == 0);
  endfunction

  class tb_cfg;
    rand int unsigned num_rx_beats = 200;
    rand int unsigned max_wait_states = 3; // <=5
    rand bit inject_illegal_md = 0;
    rand bit tx_backpressure   = 1;
    rand bit tx_inject_err     = 0;
    rand bit coalesce_mode     = 0; // 0: fijo por CTRL.SIZE; 1: coalesce
    constraint c_ws { max_wait_states inside {[0:5]}; }
  endclass
endpackage
