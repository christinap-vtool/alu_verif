//  `uvm_analysis_imp_decl(_fifo_write)
//todo `uvm_analysis_imp_decl(_fifo_read)

class alu_scoreboard extends uvm_scoreboard;
   `uvm_component_utils (alu_scoreboard)  
   parameter DATA_SIZE = 16;           //todo maybe should be found only in the defines
   parameter MUL_DATA_SIZE = 8;
   parameter FIFO_IN_DEPTH =4;
   parameter FIFO_OUT_DEPTH =4;

   bit[41:0] data_to_be_written;
   bit[15:0] control;
   bit start_bit;
   bit[1:0] operation;
   bit[(DATA_SIZE-1):0] first_operand;
   bit[(DATA_SIZE-1):0] second_operand;
   bit[16:0] result;  //16:0 and not 15:0 because of the carry out
   bit[24:0] actual_result; //Be carefull result will be  the actual_result+carry+id
   bit[24:0] value;              //here will be save the result on a read operation 
   //bit[7:0] first_operand_mul;   //we have to use only the half least significant bits
   bit[(MUL_DATA_SIZE-1):0] first_operand_mul;   //we have to use only the half least significant bits

   bit[(MUL_DATA_SIZE-1):0] second_operand_mul;  //we have to use only the half least significant bits

   bit[41:0] item_q[$];  //todo should i use as a parameter the size of the fifo??
   reg_block   m_ral_model; //register model
   int cnt_fifo_in = 0;
   int cnt_fifo_out = 0;
   bit[24:0] monitor_full_out;
   bit [24:0]actuall_full_out;  //When CNT_FIFO_OUT reaches its maximum value, this variable is set to 1.

   function new (string name = "alu_scoreboard", uvm_component parent);
      super.new(name,parent);
   endfunction

   //declare and create tlm analysis port to receive data objects from other tb components
   uvm_analysis_imp #(apb_transaction, alu_scoreboard) ap_imp;
   //instantiate the analysis port, because afterall, its a class object
   function void build_phase (uvm_phase phase);
      ap_imp = new("ap_imp", this);

      //full_in = top_tb.alu_top_module.csr_inst.csr_control_inst.full_in;
      //full_in = top_tb.dut.csr_control_inst.full_in;

      //`uvm_info("scbr", $sformatf("full_in = 0x%0h", full_in), UVM_NONE)

   endfunction


   //define action to be taken when a pkt is received via the declared analysis port
   virtual function void write (apb_transaction pkt);

      `uvm_info("write", $sformatf("data received = 0x%0h", pkt.data), UVM_NONE)
      `uvm_info("write", $sformatf("address received = 0x%0h", pkt.addr), UVM_NONE)

      `uvm_info("write", $sformatf("write operation= 0x%0h", pkt.op), UVM_NONE)
      //`uvm_info("write", $sformatf("kind received = 0x%0h", pkt.kind), UVM_NONE)


      if(pkt.slv_err == 1) begin
         `uvm_info("SCBD", $sformatf("Cause of slave error:"), UVM_NONE)

         if(((pkt.addr == 0) || (pkt.addr == 1) || (pkt.addr == 2)) && (pkt.op== 0 )) begin
            `uvm_info("SCBD", $sformatf("the master tries to read from a write only register"), UVM_NONE)
         end
         else if(((pkt.addr == 3)||(pkt.addr == 4)) && (pkt.op == 1)) begin
            `uvm_info("SCBD", $sformatf("the master tries to write in a read only register"), UVM_NONE)
         end
         else if(pkt.addr > 4) begin
            `uvm_info("SCBD", $sformatf("The address provided by the master is bigger than 4"), UVM_NONE)
         end
         else if((pkt.addr == 3) && (cnt_fifo_out == 0)) begin 
            `uvm_info("SCBD", $sformatf("The master tries to read a result from the Result register, but FIFO_OUT is empty."), UVM_NONE)
         end
         else if((pkt.addr == 0) && (cnt_fifo_in > FIFO_IN_DEPTH)) begin 
            `uvm_info("SCBD", $sformatf("The master tries to send new data to be computed, but FIFO_IN is full."), UVM_NONE)
         end
         //todo add the last bullet beacause of the slv_err is 1: The operation bits of ctrl_data are neither 2?b10 nor 2?b01.
         // else if ((pkt.op!=0) || (pkt.op!=1)) begin
         //    `uvm_info("SCBD", $sformatf("The operation bits of ctrl_data are neither 2?b10 nor 2?b01."), UVM_NONE)
         // end

         else 
            `uvm_error(get_type_name (), $sformatf("No idea from where sl_err is coming from."))

      end
      else begin
      
         case (pkt.addr)
            2'b00 : begin
               control = pkt.data;
               data_to_be_written[1:0] = control[2:1];
               data_to_be_written[9:2] = control[15:8];
               start_bit = control[0];
               `uvm_info("SCBD", $sformatf("id = 0x%0h", data_to_be_written[9:2]), UVM_NONE)

               cnt_fifo_in = cnt_fifo_in + 1;
               cnt_fifo_out = cnt_fifo_out + 1;
               `uvm_info("SCBD", $sformatf("cnt_fifo_out = %0d ",cnt_fifo_out), UVM_NONE);
            end
            2'b01 : begin
               data_to_be_written[25:10] = pkt.data;
            end
            2'b10: begin
               data_to_be_written[41:26] = pkt.data;
            end
            2'b11: begin
               value=item_q.pop_front();
               cnt_fifo_in = cnt_fifo_in - 1;
               cnt_fifo_out = cnt_fifo_out - 1;
               `uvm_info("SCBD", $sformatf("cnt_fifo_out = %0d ",cnt_fifo_out), UVM_NONE);
            end
            2'b100: begin
              monitor_full_out = pkt.data;
               `uvm_info("SCBD", $sformatf("monitor_full_out = %0d ",monitor_full_out), UVM_NONE);
            end


         endcase

         //lets make the expected pkt!//todo create a cntr for fifo in
         
         if(start_bit) begin

            //cnt_fifo_in = cnt_fifo_in + 1;
            `uvm_info("SCBD", $sformatf("cnt_fifo_in = :%0h ",cnt_fifo_in), UVM_NONE); 

            operation = data_to_be_written[1:0];
            `uvm_info("SCBD", $sformatf("operation = :%0h ",operation), UVM_NONE);

            first_operand = data_to_be_written[25:10];
            `uvm_info("SCBD", $sformatf("first_operand = :%0h ",first_operand), UVM_NONE);

            second_operand = data_to_be_written[41:26];
            `uvm_info("SCBD", $sformatf("second_operand = :%0h ",second_operand), UVM_NONE);

            //The start bit register is self clearing and
            //must return to zero as soon as the data is written in FIFO_IN.
            start_bit = 0;

            case(operation)
               2'b01 : begin
                  //addition
                  `uvm_info("SCBD", $sformatf("addition = :%0h ",operation), UVM_NONE); 

                  result = first_operand + second_operand;
                  `uvm_info("SCBD", $sformatf("result of addition = :%0h ",result), UVM_NONE); 
                  actual_result[24:17] = data_to_be_written[9:2];
                  actual_result[16:0] = result;
                  `uvm_info("SCBD", $sformatf(" HERE HERE HERE actual result of addition = :%0h ",actual_result), UVM_NONE); 
                  
                  m_ral_model.m_result_reg.predict(actual_result);
                  item_q.push_back(actual_result);  //FIFO_OUT
                  cnt_fifo_out = cnt_fifo_out + 1;
               `uvm_info("SCBD", $sformatf("cnt_fifo_out = %0d ",cnt_fifo_out), UVM_NONE);

                  if (cnt_fifo_out == FIFO_OUT_DEPTH) begin 
                     monitor_full_out = 1;
                  end
                  m_ral_model.m_monitor_reg.predict(monitor_full_out);



               end
               2'b10: begin
                  //mulpiplication
                  //That might be obvious for the addition of two DATA_SIZE numbers, but multiplying them would produce a result of (2*DATA_SIZE). 
                  //In order to avoid that and for the purpose of simplifying FIFO_OUT, the two operands of a multiplication are divided in half 
                  //and only the (DATA_SIZE/2) least significant bits are used in the multiplier.
                  `uvm_info("SCBD", $sformatf("multiplication = :%0h ",operation), UVM_NONE); 

                  first_operand_mul = first_operand[7:0]; //magic numver
                  `uvm_info("SCBD", $sformatf("first_operand_mul = :%0h ",first_operand_mul), UVM_NONE); 

                  second_operand_mul = second_operand[7:0]; //magic numbers
                  `uvm_info("SCBD", $sformatf("second_operand_mul = :%0h ",second_operand_mul), UVM_NONE); 

                  result = first_operand_mul * second_operand_mul;

                  `uvm_info("SCBD", $sformatf("result of multiplication = :%0h ",result), UVM_NONE); 
                  actual_result[24:17] = data_to_be_written[9:2];
                  actual_result[16:0] = result;
                  `uvm_info("SCBD", $sformatf("actual result of multiplication = :%0h ",actual_result), UVM_NONE); 

               
                  m_ral_model.m_result_reg.predict(actual_result);

                  item_q.push_back(actual_result);
                  
                  //cnt_fifo_out = cnt_fifo_out + 1;
                  if (cnt_fifo_out == FIFO_OUT_DEPTH) begin 
                     monitor_full_out = 1;
                  end
                  m_ral_model.m_monitor_reg.predict(monitor_full_out);

               end

            endcase
         end
      end //else no slave error
      //for (int i=0; i<item_q.size(); i++) begin 
         // todo check when alu is ready to receive data from fifo_in and the pop_frond and decrease the counter
         //pop otan pkt.addr=3
        // value=item_q.pop_front();
        // `uvm_info("SCBD", $sformatf("value = :%0d ",value), UVM_NONE); 
         //cnt_fifo_in = cnt_fifo_in -1;  
        // `uvm_info("SCBD", $sformatf("cnt_fifo_in = %0d ",cnt_fifo_in), UVM_NONE); 


       //end

      // //todo when an read operation is happening on the result reg the predict value should be updated. a pop-front operation should be take place.
      //  value=item_q.pop_front();
      //  m_ral_model.m_result_reg.predict(value);  //--> valaue = expected check on read //todo this works but null derefence

      //port apo adapter h scoreboard kai dhmiourgei reg.ob kai sygkrinw auto me to exp

 
   endfunction

endclass



//seed : 1989228659
