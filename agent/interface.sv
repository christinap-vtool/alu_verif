//interface apb_signals ();
interface interfc ();

   logic[31:0] paddr;
   logic[31:0] pwdata;
   logic[31:0] prdata;
   logic       penable;
   logic       pwrite;
   logic       psel;
   logic       clk;
   logic       rst_n;


   logic       ready;
   logic       slv_err;


endinterface

