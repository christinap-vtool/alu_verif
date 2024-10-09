`timescale 1ns/1ns
module top_tb();
  import uvm_pkg::*;
  import alu_pkg::*;
  import alu_test_pkg::*;

//table 4.1
//declaration of our signals;
/*
//todo douleuei me autes 
  reg clk, rst_n, ready, slv_err ;
  wire pwdata;
  */
  reg  clk,RST_n ;
  wire psel,penable,ready,slv_err, pwrite, rst_n;
  wire [15:0] pwdata;
  wire [31:0] prdata;
  wire [2:0]  paddr;

//declaration of the interface
  //apb_signals vintf();
   interfc vintf();
   fifo_config conf;

   assign vintf.clk = clk; 
   //assign vintf.RST_n= rst_n;
   assign rst_n = vintf.rst_n;

   assign pwdata = vintf.pwdata;
   assign psel = vintf.psel;
   assign penable = vintf.penable;
   assign pwrite = vintf.pwrite;
   assign paddr = vintf.paddr;


   assign vintf.ready = ready;
   assign vintf.slv_err = slv_err;
   assign vintf.prdata = prdata;
   
   




// initial begin
//     //uvm_config_db #(virtual apb_signals) :: set (null,"*","interfc", vintf);
//      uvm_config_db#(virtual interfc)::set(null, "*", "interfc", vintf);
//      uvm_config_db#(fifo_config)::set(null,"*","fifo_config",conf);


// end

  initial begin 
    clk =0;
   //  rst_n =1;
   //   #10 rst_n = 0;
   //   #10 rst_n =1;
   RST_n =1;
     #10 RST_n = 0;
     #10 RST_n =1;

  end
  always #10 clk = ~clk;


  // alu_top_module dut(
  alu_top_module dut(

      .clk(clk),
      //.rst_n(rst_n),
      .rst_n(rst_n & RST_n ),
      .sel(psel),
      .en(penable),
      .write(pwrite),

      .addr(paddr),
      .wdata(pwdata),
      .ready(ready),
      .slv_err(slv_err),
      .rdata(prdata)

   );

   

   initial begin
    uvm_config_db #(virtual interfc) :: set (null,"*","interfc", vintf);
    uvm_config_db#(fifo_config)::set(null,"*","fifo_config",conf);
   
     run_test();
   end
endmodule//top_tb




