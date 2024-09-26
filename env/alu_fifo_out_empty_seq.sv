//The master tries to read a result from the Result register, but FIFO_OUT is empty
class alu_fifo_out_empty_seq extends base_seq;
   `uvm_object_utils(alu_fifo_out_empty_seq)
   rand bit[15:0] data0;
   rand bit[15:0] data1;

   rand bit [7:0] id;
   rand bit[1:0]  operation;
   rand bit start_bit;
   bit[15:0] control = 0;


   bit[15:0]  result_reg;
   reg_block   m_ral_model; //register model
   uvm_status_e status;
   apb_transaction data_obj;
   uvm_reg_data_t   ref_data;   //this is for the desire value

   bit[15:0]  rdata;   //here will be saved the data that will be read from data0
   rand int wr_trans;

   constraint id_c {id >0;}
   constraint operation_c {operation inside{1,2};}
   //constraint operation_c {operation == 1;}

   constraint start_bit_c {start_bit == 1;}

   // constraint data0_c {data0 == 2;}
   // constraint data1_c {data1 == 3;}
   // constraint id_c{id == 2;}
   constraint wr_trans_c{soft wr_trans>0; soft wr_trans<4;}

   function new (string name = "alu_fifo_out_empty_seq");
      super.new(name);

   endfunction

   virtual task pre_body();
   if(!uvm_config_db #(reg_block):: get(null, "top_tb", "m_ral_model", m_ral_model))
      `uvm_fatal("seq","cannot get config")

   endtask

   virtual task body();
      `uvm_info(get_name(), "start seq", UVM_NONE)
      data_obj = apb_transaction :: type_id ::create("dtata_obj");
      //data_obj.op = write;
      

     //#600ns;  //seed 1489990371 it doesnt stop

       m_ral_model.m_result_reg.read(status,rdata);
       `uvm_info("seq", $sformatf("result bit:%0d ",rdata), UVM_NONE); 

`uvm_info(get_name(), " seq after result", UVM_NONE)


data_obj.print();


endtask
endclass

