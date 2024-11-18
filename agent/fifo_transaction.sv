class fifo_transaction extends uvm_sequence_item;


   rand bit[41:0] fifo_data;     //41-26 2nd operand, 25-10 1st operand, 9-2 id, 1-0: operation


   function new(string name = "");
      super.new (name);
   endfunction

   //bit empty;
   //bit full;
   //bit rst;
  // bit wr_en;

endclass