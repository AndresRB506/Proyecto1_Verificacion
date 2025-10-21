+incdir+aligner_tb/sv      
# DUT sources
DUT/cfs_rx_ctrl.v
DUT/cfs_tx_ctrl.v
DUT/cfs_regs.v
DUT/cfs_ctrl.v
DUT/cfs_synch_fifo.v
DUT/cfs_synch.v
DUT/cfs_edge_detect.v
DUT/cfs_aligner_core.v
DUT/cfs_aligner.v

# Testbench sources
aligner_tb/sv/tb_defs_pkg.sv
aligner_tb/sv/apb_if.sv
aligner_tb/sv/md_if.sv
aligner_tb/sv/agents/apb/apb_driver.sv
aligner_tb/sv/agents/apb/apb_monitor.sv
aligner_tb/sv/agents/md/md_rx_driver.sv
aligner_tb/sv/agents/md/md_tx_driver.sv
aligner_tb/sv/agents/md/md_monitors.sv
aligner_tb/sv/assertions/md_assertions.sv
aligner_tb/sv/assertions/apb_assertions.sv
aligner_tb/sv/report/report_logger.sv
aligner_tb/sv/scoreboard/aligner_ref_model.sv
aligner_tb/sv/scoreboard/scoreboard.sv
aligner_tb/sv/coverage/coverage.sv
aligner_tb/sv/top_tb.sv



-full64 
-sverilog 
-timescale=1ns/1ps 
-debug_access+r+w -debug_region+cell 
+vpi
-debug_access+all 
+lint=all,noVCDE 
-cm line+cond+tgl+branch+assert

