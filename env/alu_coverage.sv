class alu_coverage;

bit wr_rd;
bit[`DATA_SIZE-1 :0] data;
bit start_bit;
bit mid_rst;
cause_of_slv_err slv_err;          //we have 6 occation for the slv_error
bit [`ADDR_W : 0] addr;
operation_type operation;
//However, it should be noted that a multiplication can take up to 16 cycles, 
//while an addition lasts about 3. So, some results may be saved out of order. In FIFO_IN the data is 
//saved with the order they were sent in and also read and forwarded to the ALU in the same order. 
//But, in FIFO_OUT they are saved whenever the results are ready (and the fifo is not full).
bit out_of_order;
bit full_fifo_out;
bit full_fifo_in;



covergroup write_cg;
//Each covergroup instance contributes to the overall coverage information for the coverage type. 
//If it is true, coverage information for this covergroup instance is also tracked.
option.per_instance =1;

   wr_rd_cp: coverpoint wr_rd{
      bins wr_rd_0 = {0};
      bins wr_rd_1 = {1};
   }
   //wr_rd_cp: coverpoint wr_rd;

   wr_rd_transition_cp : coverpoint wr_rd{
      bins write_read = (1 => 0);
      bins read_write = (0 => 1);
      bins write_write = (1 => 1);
      bins read_read = (0 => 0);
   }

   operation_transition_cp : coverpoint operation{
      bins addition_addition = (addition => addition);
      bins multiplication_multiplication = (multiplication => multiplication);
      bins multiplication_addition = (multiplication => addition);
      bins addition_multiplication = (addition => multiplication);
   }

   data_cp: coverpoint data;

   addr_cp: coverpoint addr;

   slv_err_cp: coverpoint slv_err;

   operation_cp: coverpoint operation;

   full_fifo_out_cp: coverpoint full_fifo_out;

   full_fifo_in_cp: coverpoint full_fifo_in{
      ignore_bins full_fifo_in = {0};
   }


endgroup : write_cg


covergroup mid_rst_cg;
   option.per_instance = 1;

   mid_rst_cp : coverpoint mid_rst{
      ignore_bins mid_rst = {0};
   }

endgroup : mid_rst_cg

covergroup m_control_reg_cg;
   option.per_instance = 1;
   start_bit_cp :coverpoint start_bit;    //i want to be sure that i have both 0 and 1 in start bit 
endgroup : m_control_reg_cg

covergroup out_of_order_cg;
   option.per_instance = 1;
   out_of_order_cp : coverpoint out_of_order;
endgroup : out_of_order_cg


function new();
   write_cg = new();
   mid_rst_cg = new();
   m_control_reg_cg = new();
   out_of_order_cg = new();
endfunction

endclass




//2.epishs gia to operation na exw mesa sto case prosthesh , pol/mos kai sto error kai na 
//exw kai ignore thn mia timh?