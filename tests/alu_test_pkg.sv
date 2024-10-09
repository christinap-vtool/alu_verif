`ifndef ALU_TEST_PKG_SV
`define ALU_TEST_PKG_SV

package alu_test_pkg;



`include "uvm_macros.svh"

import uvm_pkg::*;

import alu_pkg::*;



`include "alu_testbase.sv"
`include "alu_base_test.sv"
//`include "alu_cntr_test.sv"

`include "alu_empty_fifo_out_test.sv"
`include "alu_write_to_read_reg.sv"
`include "alu_read_from_write_test.sv"
`include "alu_full_fifo_in_test.sv"
`include "alu_reset_test.sv"



endpackage

`endif