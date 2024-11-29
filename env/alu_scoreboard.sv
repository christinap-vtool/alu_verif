`ifndef ALU_SCOREBOARD_SV
`define ALU_SCOREBOARD_SV

`uvm_analysis_imp_decl(_ap)
`uvm_analysis_imp_decl(_rst_detected)

class alu_scoreboard extends uvm_scoreboard;
   `uvm_component_utils (alu_scoreboard)

   bit[41:0] data_to_be_written;
   bit[15:0] control;
   bit start_bit;
   bit[1:0] operation;
   bit[`DATA_SIZE-1:0] first_operand;
   bit[(`DATA_SIZE-1):0] second_operand;
   bit[16:0] result;  //16:0 and not 15:0 because of the carry out
   bit[24:0] actual_result; //result will be the actual_result+carry+id

   bit[(`MUL_DATA_SIZE-1):0] first_operand_mul;   //we have to use only the half least significant bits
   bit[(`MUL_DATA_SIZE-1):0] second_operand_mul;  //we have to use only the half least significant bits

   bit[41:0] item_q[$];
   reg_block   m_ral_model;
   int cnt_fifo_in = 0;
   int cnt_fifo_out = 0;
   bit[24:0] monitor_full_out;
   //bit [24:0]actuall_full_out;  //When CNT_FIFO_OUT reaches its maximum value, this variable is set to 2.

   bit [24:0] result_from_dut;
   bit [7:0]  id_from_dut;
   bit [7:0]  id;
   bit [24:0] array_results [bit[7:0]];
   bit[7:0] id_queue [$];  //queue with ids in order to know the order
   bit [1:0]  control_reg_addr;
   bit [1:0]  data_0_reg_addr;
   bit [1:0]  data_1_reg_addr;
   bit [1:0]  result_reg_addr;
   bit [2:0]  monitor_reg_addr;
   bit[1:0] operation_bit; //to be used within the cause_of_slave_error function

   alu_coverage cvg_obj;

   virtual interfc vintf;

   extern function void reg_address();
   extern function void cause_of_slave_error(apb_transaction pkt);
   extern function void comparison_expected_actual_pkt (apb_transaction pkt);

   //declare and create tlm analysis port to receive data objects from other tb components
   uvm_analysis_imp_ap #(apb_transaction, alu_scoreboard) ap_imp;
   uvm_analysis_imp_rst_detected #(bit, alu_scoreboard) rst_imp;

   function new (string name = "alu_scoreboard", uvm_component parent);
      super.new(name,parent);
   endfunction

   //instantiate the analysis port, because afterall, its a class object
   function void build_phase (uvm_phase phase);
      ap_imp = new("ap_imp", this);
      rst_imp   = new("rst_imp", this);
      cvg_obj = new();
      if(!uvm_config_db#(virtual interfc) :: get(this,"","interfc",vintf)) begin
         `uvm_error("","uvm_get_config interface failed\n");
      end
   endfunction

   virtual task run_phase(uvm_phase phase);
      `uvm_info("run_phase", $sformatf("inside the run phase"), UVM_NONE)
      reg_address();
      write_read_wait_states();
   endtask


   task write_read_wait_states();
      //This task is responsible for checking that the write operation has no wait states and
      //that the read operation has one wait state if there is no slave error.
      `uvm_info("SCBD", $sformatf("inside task"), UVM_HIGH)
      forever begin
         fork
            forever begin
               wait(vintf.psel ==1 && vintf.penable==1 && vintf.pwrite == 1);
               #1ns
               if(vintf.ready == 1) begin
                  cvg_obj.checker_t = apb_write;
                  cvg_obj.checker_cg.sample();
                  `uvm_info("SCBD", $sformatf("Writing of data via APB doesn't include any wait states and it happens immediately."), UVM_NONE)
               end
               else
                  `uvm_error(get_type_name (), $sformatf("The writing didn't happen immediatly"))
               wait(vintf.penable == 0);
            end

            forever begin
               `uvm_info("SCBD", $sformatf(" before 2nd wait"), UVM_DEBUG)

               wait((vintf.psel ==1) && (vintf.penable==1) && (!vintf.pwrite) && (vintf.paddr==monitor_reg_addr));
               `uvm_info("SCBD", $sformatf(" after 2nd wait"), UVM_DEBUG)

               #1ns
               if(vintf.ready == 1) begin
                  cvg_obj.checker_t = apb_read_monitor;
                  cvg_obj.checker_cg.sample();
                  `uvm_info("SCBD", $sformatf("The read transfer in this design includes no wait states when reading from the Monitor register (address 0x4)"), UVM_NONE)
               end
               else
                  `uvm_error(get_type_name (), $sformatf("Reading from monitor didn't happen immediatly"))
               wait(vintf.penable == 0);
            end

            forever begin
               `uvm_info("SCBD", $sformatf(" before 3rd wait"), UVM_DEBUG)

               wait((vintf.psel ==1) && (vintf.penable==1) && (!vintf.pwrite) && (vintf.paddr==result_reg_addr));
               //`uvm_info("SCBD", $sformatf(" after 3rd wait"), UVM_NONE)

               #1ns
               if (!vintf.slv_err) begin
                  if(vintf.ready==0)
                     `uvm_info("SCBD", $sformatf("That's normal.Reading includes one wait state."), UVM_NONE)
                  @(posedge vintf.clk);
                  #1ns
                  if(vintf.ready==1)begin
                     cvg_obj.checker_t = apb_read_no_slav_err;
                     cvg_obj.checker_cg.sample();
                     `uvm_info("SCBD", $sformatf("Expected. Reading includes one wait state."), UVM_NONE)
                  end
                  else
                     `uvm_error(get_type_name (), $sformatf("The reading didn't happen immediately after one clock cycle"))
               end
               else begin
                  if(vintf.ready == 1) begin
                     cvg_obj.checker_t = apb_read_slv_err;
                     cvg_obj.checker_cg.sample();
                     `uvm_info("SCBD", $sformatf("Reading and slave error -> No wait state."), UVM_NONE)
                  end
                  else
                     `uvm_error(get_type_name (), $sformatf("Reading and slave error should not have wait state"))
               end
               wait(vintf.penable == 0);
            end
         join
      end
   endtask


   //define action to be taken when a pkt is received via the declared analysis port
   virtual function void write_ap (apb_transaction pkt);

      cvg_obj.data = pkt.data;
      cvg_obj.addr = pkt.addr;

      `uvm_info("write", $sformatf("data received = 0x%0h", pkt.data), UVM_NONE)
      `uvm_info("write", $sformatf("address received = 0x%0h", pkt.addr), UVM_NONE)

      `uvm_info("write", $sformatf("write operation= 0x%0h", pkt.op), UVM_NONE)

      if(pkt.slv_err == 1) begin
         cvg_obj.slv_err = pkt.slv_err;
         cause_of_slave_error(pkt);
      end //pkt.slv_err == 1)
      else begin

         case (pkt.addr)
            2'b00 : begin
               control = pkt.data;
               data_to_be_written[1:0] = control[2:1];
               data_to_be_written[9:2] = control[15:8];
               start_bit = control[0];
               `uvm_info("SCBD", $sformatf("id = 0x%0h", data_to_be_written[9:2]), UVM_NONE)
               if(control[0] ==1) begin
                  if(cnt_fifo_out < `FIFO_OUT_DEPTH)
                     cnt_fifo_out = cnt_fifo_out + 1;
                  else begin
                     if(cnt_fifo_in < `FIFO_IN_DEPTH)
                        cnt_fifo_in = cnt_fifo_in + 1;
                     if(cnt_fifo_in == `FIFO_IN_DEPTH)
                        cvg_obj.full_fifo_in =1;
                  end
               end

               `uvm_info("SCBD", $sformatf("cnt_fifo_in = %0d ",cnt_fifo_in), UVM_NONE);

               `uvm_info("SCBD", $sformatf("cnt_fifo_out = %0d ",cnt_fifo_out), UVM_NONE);
               cvg_obj.wr_rd =1;

            end
            2'b01 : begin
               data_to_be_written[25:10] = pkt.data;
               cvg_obj.wr_rd =1;
               cvg_obj.data0 = pkt.data;
               cvg_obj.data0_cg.sample();
            end
            2'b10: begin
               data_to_be_written[41:26] = pkt.data;
               cvg_obj.wr_rd =1;
               cvg_obj.data1 = pkt.data;
               cvg_obj.data1_cg.sample();

            end
            2'b11: begin
               comparison_expected_actual_pkt(pkt);

               if(cnt_fifo_in > 0)
                  cnt_fifo_in = cnt_fifo_in - 1;
               else if(cnt_fifo_in == 0 && cnt_fifo_out > 0)
                  cnt_fifo_out = cnt_fifo_out - 1;
               `uvm_info("SCBD", $sformatf("cnt_fifo_out = %0d ",cnt_fifo_out), UVM_NONE)
               cvg_obj.wr_rd =0;
               cvg_obj.result_reg = pkt.data;
               cvg_obj.result_reg_cg.sample();

            end
            3'b100: begin
               monitor_full_out = pkt.data;
               `uvm_info("SCBD", $sformatf("moniror_reg = %0d ",pkt.data), UVM_NONE)
               `uvm_info("SCBD", $sformatf("monitor_full_out = %0d ",monitor_full_out), UVM_NONE)
               cvg_obj.wr_rd =0;

               if(((pkt.data[0] == 1) && cnt_fifo_out == 0 ) ||(pkt.data[0] == 0) && cnt_fifo_out != 0) begin 
                  `uvm_info("SCBD", $sformatf("Monitor register. Empty_out : all good! "), UVM_NONE)
               end
               else
                  `uvm_error(get_type_name (), $sformatf("Monitor register error regarding the empty_out. "))
               if(((pkt.data == 2 )&& (cnt_fifo_out == `FIFO_OUT_DEPTH)) || ((pkt.data == 1 )&& (cnt_fifo_out < `FIFO_OUT_DEPTH))) begin

                  `uvm_info("SCBD", $sformatf("Monitor register. FIFO_OUT is full, no new computations can begin and the user will not be able to send new data "), UVM_NONE)
               end
               else
                  `uvm_error(get_type_name (), $sformatf("Monitor register error regarding the full_out. full_out=%d,  cnt_fifo_out=%d", pkt.data, cnt_fifo_out ))
            end
         endcase

         //lets make the expected pkt!
         if(start_bit) begin
            cvg_obj.start_bit = 1;
            `uvm_info("SCBD", $sformatf("cnt_fifo_in = :%0h ",cnt_fifo_in), UVM_NONE)
            id = data_to_be_written[9:2];
            `uvm_info("SCBD", $sformatf("operation = :0x%0h ",operation), UVM_NONE)

            operation = data_to_be_written[1:0];
            `uvm_info("SCBD", $sformatf("operation = :0x%0h ",operation), UVM_NONE)

            first_operand = data_to_be_written[25:10];
            `uvm_info("SCBD", $sformatf("first_operand = :0x%0h ",first_operand), UVM_NONE)

            second_operand = data_to_be_written[41:26];
            `uvm_info("SCBD", $sformatf("second_operand = :0x%0h ",second_operand), UVM_NONE)

            //The start bit register is self clearing and
            //must return to zero as soon as the data is written in FIFO_IN.
            start_bit = 0;

            case(operation)
               2'b01 : begin
                  //addition
                  `uvm_info("SCBD", $sformatf("addition = :0x%0h ",operation), UVM_NONE)
                  result = first_operand + second_operand;
                  `uvm_info("SCBD", $sformatf("result of addition = :0x%0h ",result), UVM_NONE)
                  cvg_obj.operation = addition;
                  if((first_operand == 0) || (second_operand ==0))
                     cvg_obj.identity_element_for_addition = 1;
               end
               2'b10: begin
                  //mulpiplication
                  //That might be obvious for the addition of two DATA_SIZE numbers, but multiplying them would produce a result of (2*DATA_SIZE). 
                  //In order to avoid that and for the purpose of simplifying FIFO_OUT, the two operands of a multiplication are divided in half 
                  //and only the (DATA_SIZE/2) least significant bits are used in the multiplier.
                  `uvm_info("SCBD", $sformatf("multiplication = :0x%0h ",operation), UVM_NONE)
                  //coverage
                  if((first_operand > 255) && (second_operand > 255))
                     cvg_obj.division_in_half = 1;

                  first_operand_mul = first_operand[7:0];
                  `uvm_info("SCBD", $sformatf("first_operand_mul = :0x%0h ",first_operand_mul), UVM_NONE)

                  second_operand_mul = second_operand[7:0];
                  `uvm_info("SCBD", $sformatf("second_operand_mul = :0x%0h ",second_operand_mul), UVM_NONE)

                  result = first_operand_mul * second_operand_mul;

                  `uvm_info("SCBD", $sformatf("result of multiplication = :0x%0h ",result), UVM_NONE)

                  cvg_obj.operation = multiplication;
                  if((first_operand_mul == 1) || (second_operand_mul == 1))
                     cvg_obj.identity_element_for_multiplication = 1;
                  //`uvm_info("SCBD", $sformatf("actual result of multiplication = :0x%0h ",actual_result), UVM_NONE); 
               end
               default: begin
                  `uvm_error(get_type_name (), $sformatf("operation error op=%d", operation))
               end
            endcase //adder or multiplier
            actual_result[24:17] = data_to_be_written[9:2];
            actual_result[16:0] = result;
            array_results[id] = actual_result;

            id_queue.push_back(id);
            `uvm_info("SCBD", $sformatf("actual result = :0x%0h ",actual_result), UVM_NONE)

            `uvm_info("SCBD", $sformatf("cnt_fifo_out = %0d ",cnt_fifo_out), UVM_NONE)
            if (cnt_fifo_out == `FIFO_OUT_DEPTH) begin 
               monitor_full_out = 2;
               cvg_obj.full_fifo_out =1;
            end
            else if (cnt_fifo_out == 0) begin
               monitor_full_out = 1;
               cvg_obj.full_fifo_out =0;
            end
         end
         else
            cvg_obj.start_bit = 0;
         cvg_obj.m_control_reg_cg.sample();

      end

      cvg_obj.apb_cg.sample();

   endfunction

   virtual function void write_rst_detected(bit reset_bit);
      `uvm_info("SCBD", $sformatf("MID LIFE ",), UVM_NONE)

      if(reset_bit == 1) begin
         `uvm_info("SCBD", $sformatf("reset detected"), UVM_NONE)
         `uvm_info("SCBD", $sformatf("MID LIFE 2",), UVM_NONE)
         cnt_fifo_in = 0;
         cnt_fifo_out = 0;
         foreach (array_results[i]) begin
            array_results[i] = 0;
         end
         cvg_obj.mid_rst = 1;
      end

      cvg_obj.mid_rst_cg.sample();

   endfunction

endclass


function void alu_scoreboard::reg_address();
   //The reg_address function is called to get the address of the register from the reg_model.
   control_reg_addr = m_ral_model.m_control_reg.get_address();
   data_0_reg_addr = m_ral_model.m_data0_reg.get_address();
   data_1_reg_addr = m_ral_model.m_data1_reg.get_address();
   monitor_reg_addr = m_ral_model.m_monitor_reg.get_address();
   result_reg_addr = m_ral_model.m_result_reg.get_address();

   `uvm_info("write", $sformatf("control_reg_addr = %0d", control_reg_addr), UVM_NONE)
   `uvm_info("write", $sformatf("data_0_reg_addr= %0d", data_0_reg_addr), UVM_NONE)
   `uvm_info("write", $sformatf("data_1_reg_addr= %0d", data_1_reg_addr), UVM_NONE)
   `uvm_info("write", $sformatf("result_reg_addr = %0d", result_reg_addr), UVM_NONE)
   `uvm_info("write", $sformatf("monitor_reg_addr = %0d", monitor_reg_addr), UVM_NONE)
endfunction :reg_address

function void alu_scoreboard::cause_of_slave_error(apb_transaction pkt);
   //The cause_of_slave_error function is called when a slave error occurs to generate the corresponding information.
   `uvm_info("SCBD", $sformatf("Cause of slave error:"), UVM_NONE)
   operation_bit =pkt.data[2:1];

   if(((pkt.addr == control_reg_addr) || (pkt.addr == data_0_reg_addr) || (pkt.addr == data_1_reg_addr)) && (pkt.op== read )) begin
      `uvm_info("SCBD", $sformatf("the master tries to read from a write only register"), UVM_NONE)
      cvg_obj.slv_err =read_from_write_register;
   end
   else if(((pkt.addr == monitor_reg_addr)||(pkt.addr == result_reg_addr)) && (pkt.op == write)) begin
      `uvm_info("SCBD", $sformatf("the master tries to write in a read only register"), UVM_NONE)
      cvg_obj.slv_err =write_to_read_register;
   end
   else if((pkt.addr == result_reg_addr) && (cnt_fifo_out == 0)) begin 
      `uvm_info("SCBD", $sformatf("The master tries to read a result from the Result register, but FIFO_OUT is empty."), UVM_NONE)
      cvg_obj.slv_err =read_from_empty_fifo_out;
   end
   else if( (cnt_fifo_in >= `FIFO_IN_DEPTH)) begin 
      `uvm_info("SCBD", $sformatf("The master tries to send new data to be computed, but FIFO_IN is full."), UVM_NONE)
      cvg_obj.slv_err =write_to_full_fifo_in;
   end
   else if (((operation_bit!=1) && (operation_bit!=2)) && (pkt.addr == control_reg_addr)) begin
      `uvm_info("SCBD", $sformatf("The operation bits of ctrl_data are neither 2?b10 nor 2?b01. op=%d", operation_bit), UVM_NONE)
      cvg_obj.slv_err =false_operation;
   end
   else if((pkt.addr!=control_reg_addr) && (pkt.addr!=data_0_reg_addr ) && (pkt.addr != data_1_reg_addr) && (pkt.addr != result_reg_addr) && (pkt.addr != monitor_reg_addr)) begin
      `uvm_info("SCBD", $sformatf("The address provided by the master is bigger than 4"), UVM_NONE)
      cvg_obj.slv_err =no_available_addr;
   end
   else begin
      `uvm_error(get_type_name (), $sformatf("No idea where slv_err is coming from. op=%d", operation))
   end

endfunction :cause_of_slave_error

function void alu_scoreboard::comparison_expected_actual_pkt(apb_transaction pkt);
   //The comparison_expected_actual function is called to compare the actual result with the expected result.
   id_from_dut = pkt.data[24:17];
   result_from_dut = pkt.data;
   `uvm_info("SCBD", $sformatf("id from dut =%0d",id_from_dut), UVM_NONE);

   if(array_results.exists (id_from_dut)) begin
      if(array_results[id_from_dut] == result_from_dut) begin
         `uvm_info("SCBD", $sformatf("comparison was succesful"), UVM_NONE);
         cvg_obj.checker_t = comparison_succesful;
         cvg_obj.checker_cg.sample();
      end
      else begin
         `uvm_error(get_type_name (), $sformatf("Mismatch. Data from dut =0x%0h data drom ral =0x%0h",result_from_dut, array_results[id_from_dut]))
      end
      //some results may be saved out of order. In FIFO_IN the data is 
      //saved with the order they were sent in and also read and forwarded to the ALU in the same order. 
      //But, in FIFO_OUT they are saved whenever the results are ready (and the fifo is not full).
      if(id_from_dut == id_queue[0] ) begin
         `uvm_info("SCBD", $sformatf("in order "), UVM_NONE);
         id_queue.pop_front();
         cvg_obj.out_of_order = 0;
      end
      else begin
         `uvm_info("SCBD", $sformatf("out of order "), UVM_NONE);
         foreach (id_queue[i]) begin
            if (id_queue[i] == id_from_dut) begin
               id_queue.delete(i);
            end
         end
         cvg_obj.out_of_order = 1;
      end
      cvg_obj.out_of_order_cg.sample();
   end
   else  begin
      `uvm_error(get_type_name (), $sformatf("The id of dut =0x%0h doesn't match any of the ids in the array.",id_from_dut))
   end
endfunction : comparison_expected_actual_pkt

`endif
