//  `uvm_analysis_imp_decl(_fifo_write)
//todo `uvm_analysis_imp_decl(_fifo_read)
class alu_scoreboard extends uvm_scoreboard;
   `uvm_component_utils (alu_scoreboard)  
   parameter DATA_SIZE = 16;                      //todo maybe should be found only in the defines
   parameter MUL_DATA_SIZE = 8;
   parameter FIFO_IN_DEPTH =4;
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
   int cnt_fifo_in=0;

   function new (string name = "alu_scoreboard", uvm_component parent);
      super.new(name,parent);
   endfunction

   //declare and create tlm analysis port to receive data objects from other tb components
   uvm_analysis_imp #(apb_transaction, alu_scoreboard) ap_imp;
   //instantiate the analysis port, because afterall, its a class object
   function void build_phase (uvm_phase phase);
      ap_imp = new("ap_imp", this);
      //cnt_fifo_in =0;
      

   endfunction

   //define action to be taken when a pkt is received via the declared analysis port
   virtual function void write (apb_transaction pkt);
      `uvm_info("write", $sformatf("data received = 0x%0h", pkt.data), UVM_NONE)
      
      case (pkt.addr)
         2'b00 : begin
            control = pkt.data;
            data_to_be_written[1:0] = control[2:1];
            data_to_be_written[9:2] = control[15:8];
            start_bit = control[0];
         end
         2'b01 : begin
            data_to_be_written[25:10] = pkt.data;
         end
         2'b10: begin
            data_to_be_written[41:26] = pkt.data;
         end
      endcase

      //lets make the expected pkt!//todo create a cntr for fifo in
      if(start_bit) begin
         `uvm_info("SCBD", $sformatf("cnt_fifo_in = :%0d ",cnt_fifo_in), UVM_NONE); 

         cnt_fifo_in += 1;
         `uvm_info("SCBD", $sformatf("counter fifo in = %0d ",cnt_fifo_in), UVM_NONE); 
         if(cnt_fifo_in >= FIFO_IN_DEPTH) begin
            `uvm_info("SCBD", $sformatf("FIFO_IN is full. counter = %0d ",cnt_fifo_in), UVM_NONE); 
         end

         operation = data_to_be_written[1:0];
         `uvm_info("SCBD", $sformatf("operation = :%0d ",operation), UVM_NONE); 

         first_operand = data_to_be_written[25:10];
         `uvm_info("SCBD", $sformatf("first_operand = :%0d ",first_operand), UVM_NONE); 

         second_operand = data_to_be_written[41:26];
         `uvm_info("SCBD", $sformatf("second_operand = :%0d ",second_operand), UVM_NONE); 

         case(operation)
            2'b01 : begin
               //addition
               `uvm_info("SCBD", $sformatf("addition = :%0d ",operation), UVM_NONE); 

               result = first_operand + second_operand;
               `uvm_info("SCBD", $sformatf("result of addition = :%0d ",result), UVM_NONE); 
               actual_result[24:17] = data_to_be_written[9:2];
               actual_result[16:0] = result;
               `uvm_info("SCBD", $sformatf("actual result of addition = :%0d ",actual_result), UVM_NONE); 

               item_q.push_back(actual_result);  //FIFO_OUT

            end
            2'b10: begin 
               //mulpiplication
               //That might be obvious for the addition of two DATA_SIZE numbers, but multiplying them would produce a result of (2*DATA_SIZE). 
               //In order to avoid that and for the purpose of simplifying FIFO_OUT, the two operands of a multiplication are divided in half 
               //and only the (DATA_SIZE/2) least significant bits are used in the multiplier.
               `uvm_info("SCBD", $sformatf("multiplication = :%0d ",operation), UVM_NONE); 

               first_operand_mul = first_operand[7:0]; //magic numver
               `uvm_info("SCBD", $sformatf("first_operand_mul = :%0d ",first_operand_mul), UVM_NONE); 

               second_operand_mul = second_operand[7:0]; //magic numbers
               `uvm_info("SCBD", $sformatf("second_operand_mul = :%0d ",second_operand_mul), UVM_NONE); 

               result = first_operand_mul * second_operand;

               `uvm_info("SCBD", $sformatf("result of multiplication = :%0d ",result), UVM_NONE); 
               actual_result[24:17] = data_to_be_written[9:2];
               actual_result[16:0] = result;
               `uvm_info("SCBD", $sformatf("actual result of multiplication = :%0d ",actual_result), UVM_NONE); 
               item_q.push_back(actual_result);
            end

         endcase
      end
      //for (int i=0; i<item_q.size(); i++) begin 
         // todo check when alu is ready to receive data from fifo_in and the pop_frond and decrease the counter
         value=item_q.pop_front();
         `uvm_info("SCBD", $sformatf("value = :%0d ",value), UVM_NONE); 
         //cnt_fifo_in = cnt_fifo_in -1;  
         `uvm_info("SCBD", $sformatf("cnt_fifo_in = %0d ",cnt_fifo_in), UVM_NONE); 



       //end

      // //todo when an read operation is happening on the result reg the predict value should be updated. a pop-front operation should be take place.
       value=item_q.pop_front();
       m_ral_model.m_result_reg.predict(value);  //--> valaue = expected check on read //todo this works but null derefence

      //port apo adapter h scoreboard kai dhmiourgei reg.ob kai sygkrinw auto me to exp 

      //check calculation complete oti teleiwse h praxh shma. elegxv to shma mexri na ginei 1 kai meta dinw ligo xrono kai kanw read 

   endfunction

endclass
