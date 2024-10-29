`ifndef ALU_PKG_SV
`define ALU_PKG_SV

`include "uvm_macros.svh"

package alu_pkg;

   import uvm_pkg::*;
   //`include "top_tb.sv"
   `include "defines.sv"
   `include "reg_block.sv"
   `include "alu_env_config.sv"
   //`include "registers.sv"
   `include "fifo_transaction.sv" 
   `include "apb_transaction.sv" 
   `include "adapter.sv"
   `include "fifo_config.sv"
   `include "alu_driver.sv"
   `include "alu_monitor.sv"
   `include "fifo_sequencer.sv"
   `include "alu_agent.sv"
   //`include "fifo_sequence.sv"
   `include "fifo_virtual_sequencer.sv"
   `include "apb_virtual_seq_lib.sv"

   `include "alu_coverage.sv"

   `include "alu_scoreboard.sv"
   `include "alu_env.sv"


endpackage

`endif // ALU_PKG_SV
