//todo random read_write
class apb_seq_random extends base_seq;
   `uvm_object_utils(apb_seq_random)
   //`uvm_declare_p_sequencer(fifo_virtual_sequencer)

   rand int wr_trans;
   rand int rd_trans;
   rand int wr_delay;
   rand int rd_delay;

   
   constraint wr_trans_c{soft wr_trans>0; soft wr_trans<5;}
   constraint rd_trans_c{soft rd_trans>0; soft rd_trans<5;}
   constraint wr_delay_c{soft wr_delay>100; wr_delay<800;}
   constraint rd_delay_c{soft rd_delay>100; rd_delay<800;}
   apb_seq   a_simple_write_seq;

   

   function new (string name = "write_read_seq");
      super.new(name);
      a_simple_write_seq = apb_seq::type_id::create("a_simple_write_seq");
   endfunction
   /*

   //finish old implementation
   */
   virtual task pre_body();
   if(!uvm_config_db #(reg_block):: get(null, "top_tb", "m_ral_model", m_ral_model))
      `uvm_fatal("seq","cannot get config")

   endtask

   virtual task body();
      fork
         begin
            repeat(wr_trans)
            begin
               randomize(wr_delay);
               repeat(wr_delay) @(posedge p_sequencer.vintf.clk);
               a_simple_write_seq.start(p_sequencer.write_seqr);
            end
         end
         begin
            repeat(rd_trans)
            begin
               randomize(rd_delay);
               repeat(rd_delay) @(posedge p_sequencer.vintf.clk);
               #10000ns;
               m_ral_model.m_result_reg.read(status,rdata);
               `uvm_info("seq", $sformatf("result bit:%0d ",rdata), UVM_NONE); 
               `uvm_info(get_name(), " seq after result", UVM_NONE)
            end
         end
      join_any
      disable fork;

   endtask

endclass



///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//todo write
/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
class apb_seq_write extends base_seq;
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

      //#10000ns;

      // m_ral_model.m_result_reg.read(status,rdata);
      // `uvm_info("seq", $sformatf("result bit:%0d ",rdata), UVM_NONE); 

      // `uvm_info(get_name(), " seq after result", UVM_NONE)


      data_obj.print();


      //todo check the synchronization 
   endtask
endclass


