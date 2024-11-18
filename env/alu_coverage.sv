class alu_coverage;

   bit wr_rd;
   bit[`DATA_SIZE-1 :0] data;
   bit start_bit;
   bit mid_rst;
   cause_of_slv_err slv_err;          //we have 6 occation for the slv_error
   bit [`ADDR_W : 0] addr;
   operation_type operation;
   bit out_of_order;
   bit full_fifo_out;
   bit full_fifo_in;
   bit division_in_half;

   covergroup apb_cg;
      option.per_instance =1;

      wr_rd_cp: coverpoint wr_rd{
         bins wr_rd_0 = {0};
         bins wr_rd_1 = {1};
      }

      wr_rd_transition_cp : coverpoint wr_rd{
         bins write_read = (1 => 0);
         bins read_write = (0 => 1);
         bins write_write = (1 => 1);
         bins read_read = (0 => 0);
      }

      data_cp: coverpoint data;

      addr_cp: coverpoint addr;

      slv_err_cp: coverpoint slv_err;

   endgroup : apb_cg

   covergroup m_control_reg_cg;
      option.per_instance =1;

      operation_transition_cp : coverpoint operation{
         bins addition_addition = (addition => addition);
         bins multiplication_multiplication = (multiplication => multiplication);
         bins multiplication_addition = (multiplication => addition);
         bins addition_multiplication = (addition => multiplication);
      }

      operation_cp: coverpoint operation;

      start_bit_cp :coverpoint start_bit;    //the start bit takes both 0, 1  mallon edw

      //the two operands of a multiplication are divided in half
      //and only the (DATA_SIZE/2) least significant bits are used in the multiplier
      //lets check that the two operands had a value greater than 2^8 - 1
      division_in_half_cp : coverpoint division_in_half;

      full_fifo_out_cp: coverpoint full_fifo_out;

      full_fifo_in_cp: coverpoint full_fifo_in{
         ignore_bins full_fifo_in = {0};
      }
   endgroup : m_control_reg_cg

   covergroup out_of_order_cg;

   //However, it should be noted that a multiplication can take up to 16 cycles, 
   //while an addition lasts about 3. So, some results may be saved out of order. In FIFO_IN the data is 
   //saved with the order they were sent in and also read and forwarded to the ALU in the same order. 
   //But, in FIFO_OUT they are saved whenever the results are ready (and the fifo is not full).
   option.per_instance =1;

   out_of_order_cp : coverpoint out_of_order;

   endgroup : out_of_order_cg


   covergroup mid_rst_cg;
      option.per_instance = 1;
      mid_rst_cp : coverpoint mid_rst{
      ignore_bins mid_rst = {0};
      }

   endgroup : mid_rst_cg

   function new();
      apb_cg = new();
      m_control_reg_cg = new();
      out_of_order_cg = new();
      mid_rst_cg = new();
   endfunction

endclass