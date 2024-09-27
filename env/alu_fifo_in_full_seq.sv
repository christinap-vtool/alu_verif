//The master tries to read a result from the Result register, but FIFO_OUT is empty
class alu_fifo_in_full_seq extends base_seq;
   `uvm_object_utils(alu_fifo_in_full_seq)
   rand bit[15:0] data0;
   rand bit[15:0] data1;
   //allages gia control register
   rand bit [7:0] id;
   rand bit[1:0]  operation;
   rand bit start_bit;
   bit[15:0] control = 0;

   //telos oi allages gia control

   //bit[15:0]  result_reg;
   reg_block   m_ral_model; //register model
   uvm_status_e status;
   apb_transaction data_obj;
   uvm_reg_data_t   ref_data;   //this is for the desire value

   //bit[15:0]  rdata;   //here will be saved the data that will be read from data0
   bit[24:0]  rdata;   //here will be saved the data that will be read from data0

   rand int wr_trans;

   constraint id_c {id >0;}
   constraint operation_c {operation inside{1,2};}
   //constraint operation_c {operation == 2;}

   constraint start_bit_c {start_bit == 1;}

    //constraint data0_c {data0 == 255;}
    //constraint data1_c {data1 == 255;}
   //constraint id_c{id == 2;}
   constraint wr_trans_c{soft wr_trans>0; soft wr_trans<4;}

   function new (string name = "write_read_seq");
      super.new(name);
   endfunction

   virtual task pre_body();
   if(!uvm_config_db #(reg_block):: get(null, "top_tb", "m_ral_model", m_ral_model))
      `uvm_fatal("seq","cannot get config")

   endtask

   virtual task body();
      `uvm_info(get_name(), "start seq", UVM_NONE) 
      repeat(wr_trans) begin
         randomize(data0);
         randomize(data1);
   // //allages gia control register
         randomize(id);
         randomize(operation);
         //randomize(start_bit);
         data_obj = apb_transaction :: type_id ::create("dtata_obj");

         //data_obj.op = write;

      //here the register data0 will be written
      `uvm_info("seq", $sformatf("data to be sent:%0h ",data0), UVM_NONE)

      m_ral_model.m_data0_reg.write(status,data0);
      `uvm_info(get_name(), " seq after data 0", UVM_NONE)
      //here the register data1 will be written

      `uvm_info("seq", $sformatf("data to be sent:%0h ",data1), UVM_NONE)


      m_ral_model.m_data1_reg.write(status,data1);
      `uvm_info(get_name(), " seq after data 1", UVM_NONE)

      //here the register control will be written
      `uvm_info("seq", $sformatf("data to be sent:%0h ",data0), UVM_NONE)


      control[0] = start_bit;
      control[2:1] = operation;
      control[15:8] =id;
      `uvm_info("seq", $sformatf("istart bit:%0h ",start_bit), UVM_NONE)
      `uvm_info("seq", $sformatf("operation:%0h ",operation), UVM_NONE)
      `uvm_info("seq", $sformatf(" id:%0h ",id), UVM_NONE)
      `uvm_info("seq", $sformatf("initialization of control register:%0h ",control), UVM_NONE)


      m_ral_model.m_control_reg.write(status,control);
      //monitor register
      #600ns;
      m_ral_model.m_monitor_reg.read(status,rdata);
      `uvm_info("seq", $sformatf("monitor bit:%0d ",rdata), UVM_NONE);
      `uvm_info(get_name(), " seq after monitor", UVM_NONE)

      data_obj.print();
      end

   endtask
endclass

