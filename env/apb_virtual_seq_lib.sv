`ifndef APB_VIRTUAL_SEQ_LIB_SV
`define APB_VIRTUAL_SEQ_LIB_SV

class base_seq extends uvm_sequence #(apb_transaction);
   `uvm_object_utils(base_seq)
   `uvm_declare_p_sequencer(fifo_virtual_sequencer)
   //rand bit[2:0] addr;                             // todo check the width
   apb_transaction  data_obj;

   //constraint c_addr {addr inside{0,1,2,3,4}; }

   function new (string name = "base_seq");
      super.new(name);
   endfunction

   virtual task body();
      // data_obj = apb_transaction::type_id::create("data_obj");
      // if(!data_obj.randomize()) begin
      //    `uvm_error("FIFO_SEQUENCE","Randomize failed");
      // end

   endtask

endclass

class apb_write_read_sequence extends uvm_sequence#(apb_transaction);
   `uvm_object_utils(apb_write_read_sequence)
   `uvm_declare_p_sequencer(fifo_sequencer)


   rand bit [`APB_BUS_SIZE-1 : 0] mdata;
   rand bit [`ADDR_W :0] maddr;
   rand bit [`REG_NUMBER-1 :0] maddr;
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

endclass



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

   bit[24:0]  rdata;   //here will be saved the data that will be read from data0

   rand int wr_trans;

   constraint id_c {id >0;}
   constraint operation_c {operation dist {0:/10, [1:2]:/80, 3:/10};}

   constraint operation_c {operation dist {0:/10, [1:2]:/80, 3:/10};}

   //constraint operation_c {operation inside{1,2};}
   //constraint operation_c {operation inside{0,1,2,3};}
   constraint operation_c {operation inside{0,1,2,3};}
   //constraint operation_c {operation inside{0,1,2,3};}


   //constraint start_bit_c {start_bit == 1;}

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
         randomize(id);
         randomize(operation);
         randomize(start_bit);
         data_obj = apb_transaction :: type_id ::create("dtata_obj");

         data_obj.op = write;

         //here the register data0 will be written

         `uvm_info("seq", $sformatf("data to be sent:%0h ",data0), UVM_NONE)

         m_ral_model.m_data0_reg.write(status,data0);
         `uvm_info(get_name(), " seq after data 0", UVM_NONE)
         //here the register data1 will be written

         `uvm_info("seq", $sformatf("data to be sent:%0h ",data1), UVM_NONE)


         m_ral_model.m_data1_reg.write(status,data1);
         `uvm_info(get_name(), " seq after data 1", UVM_NONE)

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

         #800ns;

         m_ral_model.m_result_reg.read(status,rdata);
         `uvm_info("seq", $sformatf("result bit:%0h ",rdata), UVM_NONE)

         `uvm_info(get_name(), " seq after result", UVM_NONE)
         #600ns;

         //monitor register
         // m_ral_model.m_monitor_reg.read(status,rdata);
         //`uvm_info("seq", $sformatf("monitor bit:%0d ",rdata), UVM_NONE);
         //`uvm_info(get_name(), " seq after monitor", UVM_NONE)
         data_obj.print();
      end

   endtask
endclass



class write_to_read_reg extends base_seq;
   `uvm_object_utils(write_to_read_reg)
   rand bit[24:0] data;

   reg_block   m_ral_model; //register model
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
         m_ral_model.m_monitor_reg.write(status,data);
         `uvm_info(get_name(), " seq after writing to monitor register", UVM_NONE)

      end

   endtask
endclass


class read_from_write_reg extends base_seq;
   `uvm_object_utils(read_from_write_reg)
   bit[15:0] rdata;

   reg_block   m_ral_model; //register model
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
         //randomize(data);

       m_ral_model.m_data0_reg.read(status,rdata);
       `uvm_info("seq", $sformatf("result bit:%0h ",rdata), UVM_NONE)

       m_ral_model.m_data1_reg.read(status,rdata);
       `uvm_info("seq", $sformatf("result bit:%0h ",rdata), UVM_NONE)

       m_ral_model.m_control_reg.read(status,rdata);
       `uvm_info("seq", $sformatf("result bit:%0h ",rdata), UVM_NONE)

      end

   endtask
endclass


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
   constraint start_bit_c {start_bit == 1;}
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
      m_ral_model.m_result_reg.read(status,rdata);
      `uvm_info("seq", $sformatf("result bit:%0d ",rdata), UVM_NONE); 

      `uvm_info(get_name(), " seq after result", UVM_NONE)

      data_obj.print();
   endtask
endclass


//The master tries to read a result from the Result register, but FIFO_OUT is empty
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
   uvm_reg_data_t   ref_data;   //this is for the desire value

   bit[24:0]  rdata;   //here will be saved the data that will be read from data0

   rand int wr_trans;
   rand int rd_trans;


   constraint id_c {id >0;}
   constraint operation_c {operation inside{1,2};}


   constraint start_bit_c {start_bit == 1;}

    //constraint data0_c {data0 inside {1,2,3,4,5};}
    //constraint data1_c {data1 inside {1,2,3,4,5};}
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
      repeat(wr_trans) begin
         randomize(data0);
         randomize(data1);
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

      end
      repeat(rd_trans) begin
         #1000ns;
         `uvm_info("seq", $sformatf("result:%0d ",rdata), UVM_NONE);
         m_ral_model.m_result_reg.read(status, rdata);
      end

      data_obj.print();


   endtask
endclass

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
   rand bit random_reset; //trigger a reset random;y
   int counter;

   constraint id_c {id >0;}
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

               // #800ns;
               // #600ns;
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
endclass

`endif


