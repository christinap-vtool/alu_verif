interface interfc ();

   logic[`ADDR_W:0] paddr;
   logic[(`APB_BUS_SIZE-1):0] pwdata;
   logic[(`APB_BUS_SIZE-1):0] prdata;
   logic       penable;
   logic       pwrite;
   logic       psel;
   logic       clk;
   logic       rst_n;
   logic       presetn;


   logic       ready;
   logic       slv_err;


endinterface

