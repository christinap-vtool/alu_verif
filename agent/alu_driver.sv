class alu_driver extends uvm_driver #(apb_transaction);
   `uvm_component_utils (alu_driver)
   parameter DATA_WIDTH = 16;                      //todo maybe should be found only in the defines
   parameter MUL_DATA_SIZE = 8;                    //todo maybe should be found only in the defines

   function new(string name ="alu_driver", uvm_component parent = null);
      super.new (name, parent);
   endfunction

   //declare virtual interface handle and get them in build phase
   virtual interfc vintf;
   apb_transaction data_obj;

   bit rw;

   fifo_config fifo_conf;

   virtual function void build_phase (uvm_phase phase);
      super.build_phase(phase);
      data_obj = apb_transaction::type_id::create("data_obj");
      if(!uvm_config_db #(virtual interfc) :: get (this,"","interfc", vintf)) begin    
         `uvm_fatal (get_type_name (), "Didn't get handle to virtual interface")
      end
      if(!uvm_config_db #(fifo_config) :: get(this,"","fifo_config", fifo_conf))
         `uvm_fatal (get_type_name (),"uvm_get_config config failed\n");
   endfunction

   task run_phase(uvm_phase phase);
      #1ns;
      //reset
      // if(vintf.rst_n == 1) begin
      //     @(negedge vintf.rst_n);
      // end
      // @(posedge vintf.rst_n);
      //     `uvm_info(get_name(), "got through RESET", UVM_NONE) 

      // if(vintf.rst_n == 0) begin
      //     @(negedge vintf.rst_n);
      // end
      // @(posedge vintf.rst_n);
      //     `uvm_info(get_name(), "got through RESET", UVM_NONE)


      init_signals();
      `uvm_info(get_name(), "patates2", UVM_NONE) 
      forever begin
         seq_item_port.get_next_item (data_obj);
         `uvm_info("DRIVER", $sformatf("data_obj.op:%0d ",data_obj.op), UVM_NONE); 
         if( data_obj.write == 1) begin
            //if( rw == 1) begin
            `uvm_info(get_name(), "patates3a", UVM_NONE)
            write_data();
            `uvm_info(get_name(), "patates3", UVM_NONE)
         end else begin
            `uvm_info(get_name(), "hey i'm before read task", UVM_NONE)
            read_data();
            `uvm_info(get_name(), "hey i'm after read task", UVM_NONE)
         end
         seq_item_port.item_done();
      end
   endtask

   task init_signals();
      `uvm_info(get_name(), "hello i'm inside init_signal task", UVM_NONE) 
      // if( data_obj.op == write) begin
      //if( rw == 1)begin
      `uvm_info(get_name(), "initialiazation of signals.  Let's start", UVM_NONE) 
      vintf.rst_n <= 0;
      vintf.paddr <= 0;
      vintf.pwdata <= 0;
      vintf.pwrite <= 0;
      vintf.psel <= 0;
      vintf.penable <= 0;
   endtask

   task write_data();
      vintf.psel <= 1;
      vintf.paddr <= data_obj.addr;
      vintf.pwdata <= data_obj.data;
      vintf.rst_n <= 1;
      vintf.pwrite <= 1;
      `uvm_info(get_name(), "write task before vintf.clk", UVM_NONE) 
      `uvm_info("DRIVER", $sformatf("vintf.paddr:%0d ",vintf.paddr), UVM_NONE); 

      @(posedge vintf.clk);
      `uvm_info("DRIVER", $sformatf("vintf.pwdata:%0d ",vintf.pwdata), UVM_NONE); 

      `uvm_info(get_name(), "write task after vintf.clk", UVM_NONE) 
      vintf.penable <= 1;
      @(negedge vintf.ready);
      vintf.penable <= 0;
      `uvm_info(get_name(), "write task after vintf.ready", UVM_NONE) 
      //vintf.psel=0;
      data_obj.slv_err = vintf.slv_err;
   endtask

   task read_data();
      vintf.psel <= 1;
      vintf.paddr <= data_obj.addr;
      vintf.rst_n <= 1;
      vintf.pwrite <= 0;

      @(posedge vintf.clk);
      vintf.penable <= 1;
      `uvm_info(get_name(), "read task after vintf.clk", UVM_NONE) 
      `uvm_info("DRIVER", $sformatf("vintf.ready:%0d ",vintf.ready), UVM_NONE);

      if (vintf.ready == 0) begin
         @(posedge vintf.ready ); //auto
      end

      `uvm_info(get_name(), "read  task after vintf.ready", UVM_NONE) 
      vintf.psel=0;   //auto
      vintf.penable <= 0;
      data_obj.data = vintf.prdata;
      data_obj.slv_err = vintf.slv_err;
   endtask


endclass

