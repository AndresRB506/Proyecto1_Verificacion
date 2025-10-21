
// apb_assertions.sv - SVA: <=5 wait-states por transferencia APB
module apb_assertions(apb_if apb);
  default clocking cb @(posedge apb.pclk); endclocking
  default disable iff (!apb.preset_n);

  sequence s_apb_start; apb.psel && !apb.penable; endsequence

  property p_apb_wait_states_le_5;
    s_apb_start |-> ##1 apb.penable ##[0:5] apb.pready;
  endproperty
  a_apb_wait_states_le_5: assert property (p_apb_wait_states_le_5);
endmodule
