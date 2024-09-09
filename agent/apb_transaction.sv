
//maybe that should be change to apb transaction
class apb_transaction extends uvm_sequence_item;
   `uvm_object_utils(apb_transaction)

   parameter DATA_WIDTH = 16;
   parameter MUL_DATA_SIZE = 8;

   rand wr_rd_type              op; //indicates whether the transfer is read or write
   rand logic                   write;
   rand logic[31 : 0] data;  //this, depending on the address, represents either control or data0 or data1
   rand logic[3:0]              addr;   //todo check the width 

   // rand bit                   write;
   // rand bit[DATA_WIDTH-1 : 0] data;  //this, depending on the address, represents either control or data0 or data1
   // rand bit[3:0]              addr;   //todo check the width 

   //output signals of dut for apb transaction
   logic  ready;
   logic  slv_err;
   logic [DATA_WIDTH-1 : 0] prdata;

   // rand bit[15:0] data0;
   // rand bit[15:0] data1;
   // rand bit[15:0] control;

   //bit empty;
   //bit full;
   //bit rst;
  // bit wr_en;

  constraint c_addr {addr inside{0,1,2,3,4}; }   // constraint c_addr {addr < 5; }


   function new(string name = "");
      super.new (name);
   endfunction 


endclass: apb_transaction