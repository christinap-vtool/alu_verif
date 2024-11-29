`ifndef APB_VIRTUAL_SEQ_LIB_SV
`define APB_VIRTUAL_SEQ_LIB_SV

class base_seq extends uvm_sequence #(apb_transaction);
   `uvm_object_utils(base_seq)
   `uvm_declare_p_sequencer(fifo_virtual_sequencer)

   apb_transaction  data_obj;

   function new (string name = "base_seq");
      super.new(name);
   endfunction

   virtual task body();
   endtask

endclass : base_seq

class apb_write_read_sequence extends uvm_sequence#(apb_transaction);
   `uvm_object_utils(apb_write_read_sequence)
   `uvm_declare_p_sequencer(fifo_sequencer)

   rand bit [`APB_BUS_SIZE-1 : 0] mdata;
   rand bit [`ADDR_W :0] maddr;
   rand wr_rd_type operation;

   constraint addr_c{maddr >4;}

   function new (string name ="");
      super.new(name);
   endfunction


   virtual task body();
      `uvm_info(get_name,$sformatf("i'm in the body"), UVM_DEBUG)
      req = apb_transaction::type_id::create("req");
      `uvm_info(get_name,$sformatf("after start_item"), UVM_DEBUG)

      if ( !req.randomize() with {
         addr      == maddr;
         data      == mdata;
         op        == operation;
         })

      begin
         `uvm_fatal(get_name(), "APB item randomization failed")
      end else begin 
         `uvm_info(get_name(), $psprintf("Transaction to be sent is \n%s", req.sprint()), UVM_NONE)
      end

      start_item(req);
      finish_item(req);

      `uvm_info(get_name(), "Item finished. Out of body!", UVM_HIGH)

   endtask

endclass : apb_write_read_sequence



class apb_seq extends base_seq;
   `uvm_object_utils(apb_seq)
   rand bit[15:0] data0;
   rand bit[15:0] data1;
   rand bit [7:0] id;
   rand bit[1:0]  operation;
   rand bit start_bit;
   bit[15:0] control = 0;

   reg_block   m_ral_model; //register model
   uvm_status_e status;
   apb_transaction data_obj;

   bit[24:0]  rdata;   //here will be saved the data that will be read

   rand int wr_trans;
   bit[15:0]  peek_value;

   constraint id_c {unique {id}; id>0;}

   constraint operation_c {operation dist {0:/5, 1:/45, 2:/45, 3:/5};}
  

   constraint start_bit_c {start_bit == 1;}
   constraint data0_c {data0 dist {0:/10, 1:/10, [2:$]:/80};}
   constraint data1_c {data1 dist {0:/10, 1:/10, [2:$]:/80};}

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
         randomize(id);
         randomize(operation);
         randomize(start_bit);
         data_obj = apb_transaction :: type_id ::create("dtata_obj");

         data_obj.op = write;

         //here the register data0 will be written

         `uvm_info("seq", $sformatf("data to be sent:%0h ",data0), UVM_NONE)

         m_ral_model.m_data0_reg.write(status,data0);

         //m_ral_model.m_data0_reg.peek(status, peek_value);
         //`uvm_info("seq", $sformatf("peek_value_data0:%0h ",peek_value), UVM_NONE)
         `uvm_info(get_name(), " seq after data 0", UVM_NONE)

         //here the register data1 will be written
         `uvm_info("seq", $sformatf("data to be sent:%0h ",data1), UVM_NONE)

         m_ral_model.m_data1_reg.write(status,data1);

         `uvm_info(get_name(), " seq after data 1", UVM_NONE)
         //m_ral_model.m_data1_reg.peek(status, peek_value);
         //`uvm_info("seq", $sformatf("peek_value_data1:%0h ",peek_value), UVM_NONE)
         
         //here the register control will be written
         `uvm_info("seq", $sformatf("data to be sent:%0h ",control), UVM_NONE)


         control[0] = start_bit;
         control[2:1] = operation;
         control[15:8] =id;
         `uvm_info("seq", $sformatf("start bit:%0h ",start_bit), UVM_NONE)
         `uvm_info("seq", $sformatf("operation:%0h ",operation), UVM_NONE)
         `uvm_info("seq", $sformatf(" id:%0h ",id), UVM_NONE)
         `uvm_info("seq", $sformatf("initialization of control register:%0h ",control), UVM_NONE)

         #600ns;
         m_ral_model.m_control_reg.write(status,control);
         #20ns;

          m_ral_model.m_control_reg.peek(status, peek_value);
         `uvm_info("seq", $sformatf("peek_value_cntrol:%0h ",peek_value), UVM_NONE)
         `uvm_info("seq", $sformatf("peek_value_cntrol_start_bit:%0h ",peek_value[0]), UVM_NONE)
         if (peek_value[0] == 0) begin
            `uvm_info("seq", $sformatf("Start bit is self clearing. peek_value_cntrol_start_bit:%0h ",peek_value[0]), UVM_NONE)
         end
         else
            `uvm_error(get_type_name (), $sformatf("Start bit is self clearing. It should be 0"))

         #800ns;

         m_ral_model.m_result_reg.read(status,rdata);
         `uvm_info("seq", $sformatf("result bit:%0h ",rdata), UVM_NONE)

         `uvm_info(get_name(), " seq after result", UVM_NONE)
         #600ns;

         //monitor register
         // m_ral_model.m_monitor_reg.read(status,rdata);
         // `uvm_info("seq", $sformatf("monitor bit:%0d ",rdata), UVM_NONE);
         // `uvm_info(get_name(), " seq after monitor", UVM_NONE)
         data_obj.print();
      end

   endtask
endclass : apb_seq


//The master tries to write in a Read Only register. The only RO
//registers in this design are the Result register and the Monitor Register
class write_to_read_reg extends base_seq;
   `uvm_object_utils(write_to_read_reg)
   rand bit[24:0] data;

   reg_block   m_ral_model;
   uvm_status_e status;
   apb_transaction data_obj;
   rand int wr_trans;

   constraint wr_trans_c{soft wr_trans>0; soft wr_trans<4;}

   function new (string name = "write_to_read_reg");
      super.new(name);
   endfunction

   virtual task pre_body();
   if(!uvm_config_db #(reg_block):: get(null, "top_tb", "m_ral_model", m_ral_model))
      `uvm_fatal("seq","cannot get config")
   endtask

   virtual task body();
      `uvm_info(get_name(), "start seq", UVM_NONE)
      repeat(wr_trans) begin
         randomize(data);

         m_ral_model.m_result_reg.write(status,data);
         `uvm_info(get_name(), " seq after writing to result register ", UVM_NONE)
         #100ns;
         m_ral_model.m_monitor_reg.write(status,data);
          `uvm_info(get_name(), " seq after writing to monitor register", UVM_NONE)

      end

   endtask
endclass : write_to_read_reg

//The master tries to read from a WO register
class read_from_write_reg extends base_seq;
   `uvm_object_utils(read_from_write_reg)
   bit[15:0] rdata;

   reg_block   m_ral_model;
   uvm_status_e status;
   apb_transaction data_obj;
   rand int wr_trans;

   constraint wr_trans_c{soft wr_trans>0; soft wr_trans<4;}

   function new (string name = "read_from_write_reg");
      super.new(name);
   endfunction

   virtual task pre_body();
   if(!uvm_config_db #(reg_block):: get(null, "top_tb", "m_ral_model", m_ral_model))
      `uvm_fatal("seq","cannot get config")
   endtask

   virtual task body();
      `uvm_info(get_name(), "start seq", UVM_NONE)
      repeat(wr_trans) begin

       m_ral_model.m_data0_reg.read(status,rdata);
       `uvm_info("seq", $sformatf("result bit:%0h ",rdata), UVM_NONE)

       m_ral_model.m_data1_reg.read(status,rdata);
       `uvm_info("seq", $sformatf("result bit:%0h ",rdata), UVM_NONE)

       m_ral_model.m_control_reg.read(status,rdata);
       `uvm_info("seq", $sformatf("result bit:%0h ",rdata), UVM_NONE)
      end

   endtask
endclass : read_from_write_reg


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

   bit[15:0]  rdata;   //here will be saved the data that will be read from data0
   rand int wr_trans;

   constraint id_c {unique {id}; id>0;}
   constraint operation_c {operation inside{1,2};}
   constraint start_bit_c {start_bit == 1;}
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
      m_ral_model.m_result_reg.read(status,rdata);
      `uvm_info("seq", $sformatf("result bit:%0d ",rdata), UVM_NONE); 

      `uvm_info(get_name(), " seq after result", UVM_NONE)

      data_obj.print();
   endtask
endclass : alu_fifo_out_empty_seq


class alu_reset_seq extends base_seq;
   `uvm_object_utils(alu_reset_seq)
   rand bit[15:0] data0;
   rand bit[15:0] data1;
   rand bit [7:0] id;
   rand bit[1:0]  operation;
   rand bit start_bit;
   bit[15:0] control = 0;


   reg_block   m_ral_model; //register model
   uvm_status_e status;
   apb_transaction data_obj;

   bit[24:0]  rdata;   //here will be saved the data that will be read from data0

   rand int wr_trans;
   rand int wr_trans_after_reset;
   rand bit random_reset; //trigger a reset randomly
   int counter;

   constraint id_c {unique {id}; id>0;}
   constraint operation_c {operation inside{1,2};}
   //constraint operation_c {operation == 2;}

   //constraint start_bit_c {start_bit == 1;}

    //constraint data0_c {data0 == 255;}
    //constraint data1_c {data1 == 255;}
   //constraint id_c{id == 2;}
   constraint wr_trans_c{soft wr_trans>0; soft wr_trans<4;}

   function new (string name = "alu_reset_seq");
      super.new(name);
   endfunction

   virtual task pre_body();
   if(!uvm_config_db #(reg_block):: get(null, "top_tb", "m_ral_model", m_ral_model))
      `uvm_fatal("seq","cannot get config")

   endtask

   virtual task body();
      `uvm_info(get_name(), "start seq", UVM_NONE)
      counter=0;
      fork
         begin
            repeat(wr_trans) begin
               randomize(data0);
               randomize(data1);
               randomize(id);
               randomize(operation);
               randomize(start_bit);
               data_obj = apb_transaction :: type_id ::create("dtata_obj");

               data_obj.op = write;

               //here the register data0 will be written
               `uvm_info("seq", $sformatf("data to be sent:%0h ",data0), UVM_DEBUG)

               m_ral_model.m_data0_reg.write(status,data0);
               `uvm_info(get_name(), " seq after data 0", UVM_DEBUG)
               //here the register data1 will be written

               `uvm_info("seq", $sformatf("data to be sent:%0h ",data1), UVM_DEBUG)


               m_ral_model.m_data1_reg.write(status,data1);
               `uvm_info(get_name(), " seq after data 1", UVM_DEBUG)

               //here the register control will be written
               `uvm_info("seq", $sformatf("data to be sent:%0h ",control), UVM_DEBUG)


               control[0] = start_bit;
               control[2:1] = operation;
               control[15:8] =id;
               `uvm_info("seq", $sformatf("start bit:%0h ",start_bit), UVM_DEBUG)
               `uvm_info("seq", $sformatf("operation:%0h ",operation), UVM_DEBUG)
               `uvm_info("seq", $sformatf("id:%0h ",id), UVM_DEBUG)
               `uvm_info("seq", $sformatf("initialization of control register:%0h ",control), UVM_DEBUG)

               #600ns;
               m_ral_model.m_control_reg.write(status,control);

               #800ns;
               `uvm_info(get_name(), " reset de-asserted:!", UVM_NONE)

               m_ral_model.m_result_reg.read(status,rdata);
               `uvm_info("seq", $sformatf("result bit:%0h ",rdata), UVM_DEBUG)

               `uvm_info(get_name(), " seq after result", UVM_DEBUG)
               #600ns;
               data_obj.print();
               counter +=1;
            end
         end
         begin
         wait(counter >= wr_trans/2);
         `uvm_info(get_name(), " Random reset triggered!", UVM_NONE)
         p_sequencer.vintf.rst_n = 0;
         #50ns;
         p_sequencer.vintf.rst_n = 1;
         #200ns;
        end
      join 
      disable fork;
   endtask
endclass : alu_reset_seq





class alu_fifo_in_full_seq extends base_seq;
   `uvm_object_utils(alu_fifo_in_full_seq)
   rand bit[15:0] data0;
   rand bit[15:0] data1;
   rand bit [7:0] id;
   rand bit[1:0]  operation;
   rand bit start_bit;
   bit[15:0] control = 0;

   reg_block   m_ral_model; //register model
   uvm_status_e status;
   apb_transaction data_obj;

   bit[24:0]  rdata;   //here will be saved the data that will be read from data0

   rand int wr_trans;
   rand int rd_trans;


   rand bit[7:0] id_queue[$];
   bit flag = 0;
   int cnt_monitor = 0;
   constraint id_c {unique {id}; id>0;}
   //constraint id_queue_c {unique {id_queue};}

   constraint operation_c {operation inside{1,2};}

   constraint start_bit_c {start_bit == 1;}

   constraint wr_trans_c{soft wr_trans>0; soft wr_trans<4;}
   constraint rd_trans_c{soft rd_trans>0; soft rd_trans<4;}

   function new (string name = "write_read_seq");
      super.new(name);
   endfunction


   virtual task pre_body();
   if(!uvm_config_db #(reg_block):: get(null, "top_tb", "m_ral_model", m_ral_model))
      `uvm_fatal("seq","cannot get config")

   endtask

   virtual task body();
      `uvm_info(get_name(), "start seq", UVM_NONE) 

      `uvm_info("seq", $sformatf("size of queue:%0d  ",id_queue.size()), UVM_NONE)

      for(int i=0; i< wr_trans; i++) begin
         randomize(id);
         `uvm_info("seq", $sformatf("i, randomize id:%0d %0h ",i, id), UVM_NONE)
         foreach(id_queue[i]) begin
            if(id_queue[i]== id) begin
               flag = 1;
            end
         end
         if (!flag) begin
            id_queue.push_back(id);
         end
         else begin
            i = i-1;
         end
         flag = 0;
      end
      `uvm_info("seq", $sformatf("size of queue:%0d  ",id_queue.size()), UVM_NONE)

      m_ral_model.m_monitor_reg.read(status,rdata);
      `uvm_info("seq", $sformatf("monitor bit:%0d ",rdata), UVM_NONE);
      `uvm_info(get_name(), " seq after monitor", UVM_NONE)
      repeat(wr_trans) begin
         randomize(data0);
         randomize(data1);

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
         //control[15:8] =id;
         // id = id_queue.pop_front();
         // `uvm_info("seq", $sformatf("id from queue:%0h ",id), UVM_NONE)

         control[15:8] =id_queue.pop_front();

         `uvm_info("seq", $sformatf("istart bit:%0h ",start_bit), UVM_NONE)
         `uvm_info("seq", $sformatf("operation:%0h ",operation), UVM_NONE)
         `uvm_info("seq", $sformatf(" id:%0h ",id), UVM_NONE)
         `uvm_info("seq", $sformatf("initialization of control register:%0h ",control), UVM_NONE)


         m_ral_model.m_control_reg.write(status,control);
         //monitor register
         #600ns;
         if(cnt_monitor == 6) begin
            m_ral_model.m_monitor_reg.read(status,rdata);
            `uvm_info("seq", $sformatf("monitor bit:%0d ",rdata), UVM_NONE);
            `uvm_info(get_name(), " seq after monitor", UVM_NONE)
         end

      end
      repeat(rd_trans) begin
         #1000ns;
         m_ral_model.m_result_reg.read(status, rdata);
         `uvm_info("seq", $sformatf("result:%0d ",rdata), UVM_NONE);

      end

      data_obj.print();


   endtask
endclass : alu_fifo_in_full_seq
`endif