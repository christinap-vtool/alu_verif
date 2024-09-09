class base_seq extends uvm_sequence #(apb_transaction);
   `uvm_object_utils(base_seq)
   `uvm_declare_p_sequencer(fifo_virtual_sequencer)
   rand bit[2:0] addr;                             // todo check the width
   apb_transaction  data_obj;

   constraint c_addr {addr inside{0,1,2,3,4}; }

   function new (string name = "base_seq");
      super.new(name);
   endfunction

   virtual task body();
      data_obj = apb_transaction::type_id::create("data_obj");
      if(!data_obj.randomize()) begin
         `uvm_error("FIFO_SEQUENCE","Randomize failed");
      end
      // start_item(data_obj);
      // finish_item(data_obj);
   endtask

endclass

class apb_seq extends base_seq;
   `uvm_object_utils(apb_seq)
   //`uvm_declare_p_sequencer(fifo_virtual_sequencer)

   rand bit[15:0] data0;
   rand bit[15:0] data1;
   //allages gia control register
   rand bit [7:0] id;
   rand bit[1:0]  operation;
   rand bit start_bit;
   bit[15:0] control = 0;

   //telos oi allages gia control

   bit[15:0]  result_reg;
   reg_block   m_ral_model; //register model
   uvm_status_e status;
   apb_transaction data_obj;
   uvm_reg_data_t   ref_data;   //this is for the desire value

   bit[15:0]  rdata;   //here will be saved the data that will be read from data0

   constraint id_c {id >0;}
   constraint operation_c {operation inside{1,2};}
   constraint start_bit_c {start_bit == 1;}

   //  bit[1:0] operation;
   //  bit[9:2] id;
   //  bit[25:10] first_operant;
   //  bit[41:26] second_operand;
   //  bit[41:0] data_to_be_written; 
   // fifo_base_seq fifo_seq;

   function new (string name = "write_read_seq");
      super.new(name);
      //fifo_seq=fifo_base_seq::type_id::create("fifo_seq");
   endfunction
   /*

   //finish old implementation
   */
   virtual task pre_body();
   if(!uvm_config_db #(reg_block):: get(null, "top_tb", "m_ral_model", m_ral_model))
      `uvm_fatal("seq","cannot get config")

   endtask

   virtual task body();
      `uvm_info(get_name(), "start seq", UVM_NONE) 
      data_obj = apb_transaction :: type_id ::create("dtata_obj");
      //start_item(data_obj);
      data_obj.op = write;

      //here the register data0 will be written
      `uvm_info(get_name(), "patates seq", UVM_NONE) 

      `uvm_info("seq", $sformatf("data to be sent:%0d ",data0), UVM_NONE); 

      m_ral_model.m_data0_reg.write(status,data0);
      `uvm_info(get_name(), " seq after data 0", UVM_NONE)
      //here the register data1 will be written

      `uvm_info("seq", $sformatf("data to be sent:%0d ",data1), UVM_NONE); 

      m_ral_model.m_data1_reg.write(status,data1);
      `uvm_info(get_name(), " seq after data 1", UVM_NONE)

      //here the register control will be written
      `uvm_info("seq", $sformatf("data to be sent:%0d ",data0), UVM_NONE); 


      control[0] = start_bit;
      control[2:1] = operation;
      control[15:8] =id;
      `uvm_info("seq", $sformatf("istart bit:%0d ",start_bit), UVM_NONE); 
      `uvm_info("seq", $sformatf("operation:%0d ",operation), UVM_NONE); 
      `uvm_info("seq", $sformatf(" id:%0d ",id), UVM_NONE); 
      `uvm_info("seq", $sformatf("initialization of control register:%0d ",control), UVM_NONE); 

      #600ns;
      m_ral_model.m_control_reg.write(status,control);


      //   m_ral_model.m_monitor_reg.read(status,rdata);
      //    `uvm_info("seq", $sformatf("mobitor reg:%0d ",rdata), UVM_NONE); 

      //     `uvm_info(get_name(), " seq after monitor", UVM_NONE)

      //#400ns;  //seed 1489990371 it doesnt stop
      #10000ns;

      m_ral_model.m_result_reg.read(status,rdata);
      `uvm_info("seq", $sformatf("result bit:%0d ",rdata), UVM_NONE); 

      `uvm_info(get_name(), " seq after result", UVM_NONE)


      //if i want to get the desired value"
      // ref_data = ral.m_data0_reg.get();   //get the desired value
      // `uvm_info("seq",$sformatf("mirror value backdoor:%0d, ref_data"),UVM_NONE);
      // ral.m_data1_reg.write(status,data1);
      // ral.m_control_reg.write(status,control);
      // `uvm_info(get_name(), "patates seq", UVM_NONE) 
      // #1ns;  //todo check the synchronization 
      // ral.m_control_reg.result.read(status,result_reg);

      data_obj.print();
      //start_item(data_obj);
      //finish_item(data_obj);

      //todo check the synchronization 
   endtask
endclass




