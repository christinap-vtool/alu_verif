
//maybe that should be change to apb transaction
class apb_transaction extends uvm_sequence_item;
   `uvm_object_utils(apb_transaction)


   rand wr_rd_type              op; //indicates whether the transfer is read or write
   rand logic                   write;
   rand logic[`APB_BUS_SIZE-1 : 0]           data;  //this, depending on the address, represents either control or data0 or data1
   rand logic[`ADDR_W : 0]              addr;
   //output signals of dut for apb transaction
   logic  ready;
   logic  slv_err;

   constraint c_addr {soft addr inside{0,1,2,3,4};}

   function new(string name = "");
      super.new (name);
   endfunction

endclass: apb_transaction