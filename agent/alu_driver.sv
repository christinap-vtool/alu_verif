class alu_driver extends uvm_driver #(apb_transaction);
   `uvm_component_utils (alu_driver)

   function new(string name ="alu_driver", uvm_component parent = null);
      super.new (name, parent);
   endfunction

   //declare virtual interface handle and get them in build phase
   virtual interfc vintf;
   apb_transaction data_obj;
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

      forever begin
         #1ns;
         //reset
         if(vintf.presetn == 0) begin
            @(posedge vintf.presetn);
            `uvm_info(get_name(), "out of RESET", UVM_NONE)
         end
         `uvm_info(get_name(), "got through RESET", UVM_NONE)

         init_signals();
         `uvm_info(get_name(), "after the initialization of the signals", UVM_HIGH)
            fork
               do_drive();
               reset();
            join_any 
            disable fork;
      end  //forever begin
   endtask //run_phase

   task init_signals();
      `uvm_info(get_name(), "hello i'm inside init_signal task", UVM_DEBUG)

      `uvm_info(get_name(), "initialiazation of signals. Let's start", UVM_HIGH)
      vintf.paddr   <= 0;
      vintf.pwdata  <= 0;
      vintf.pwrite  <= 0;
      vintf.psel    <= 0;
      vintf.penable <= 0;
   endtask

   task do_drive();
      forever begin
         seq_item_port.get_next_item (data_obj);
         `uvm_info("DRIVER", $sformatf("data_obj.op:%0d ",data_obj.op), UVM_HIGH)

         if( data_obj.write == 1) begin
            `uvm_info(get_name(), "write_data will be called", UVM_DEBUG)
            write_data();
            `uvm_info(get_name(), "after the write task has been called", UVM_DEBUG)
         end else begin
            `uvm_info(get_name(), "before read task", UVM_DEBUG)
            read_data();
            `uvm_info(get_name(), "after read task", UVM_DEBUG)
         end
         seq_item_port.item_done(data_obj);
      end
      endtask //do_drive

   task write_data();
      vintf.psel   <= 1;
      vintf.paddr   <= data_obj.addr;
      vintf.pwdata <= data_obj.data;
      vintf.pwrite <= 1;
      `uvm_info(get_name(), "write task before vintf.clk", UVM_DEBUG)
      `uvm_info("DRIVER", $sformatf("vintf.paddr:%0d ",vintf.paddr), UVM_NONE)

      @(posedge vintf.clk);
      `uvm_info("DRIVER", $sformatf("vintf.pwdata:%0d ",vintf.pwdata), UVM_NONE)

      `uvm_info(get_name(), "write task after vintf.clk", UVM_DEBUG)
      vintf.penable <= 1;
      @(posedge vintf.clk);

      `uvm_info("DRIVER", $sformatf("vintf.penable:%0d ",vintf.penable), UVM_NONE)

       if (vintf.ready == 0) begin
         `uvm_info(get_name(), "inside vintf.ready if", UVM_DEBUG)
         @(posedge vintf.ready );
         `uvm_info("DRIVER", $sformatf("vintf.ready:%0d ",vintf.ready), UVM_NONE)
      end

      vintf.penable <= 0;
      vintf.psel <= 0;

      `uvm_info(get_name(), "write task after vintf.ready", UVM_DEBUG)
      data_obj.slv_err = vintf.slv_err;
   endtask

   task read_data();
      vintf.psel   <= 1;
      vintf.paddr  <= data_obj.addr;
      vintf.pwrite <= 0;

      @(posedge vintf.clk);
      vintf.penable <= 1;
      `uvm_info(get_name(), "read task after vintf.clk", UVM_DEBUG)
      `uvm_info("DRIVER", $sformatf("vintf.ready:%0d ",vintf.ready), UVM_NONE)

       if (vintf.ready == 0) begin
         `uvm_info(get_name(), "inside vintf.ready if", UVM_DEBUG)
         @(negedge vintf.ready );
         `uvm_info("DRIVER", $sformatf("vintf.ready:%0d ",vintf.ready), UVM_NONE)
      end
      else begin
         @(posedge vintf.clk);
      end

      `uvm_info(get_name(), "read  task after vintf.ready", UVM_DEBUG)
      vintf.psel=0;
      vintf.penable <= 0;
      `uvm_info("DRIVER", $sformatf("vintf.prdata: %0h ",vintf.prdata), UVM_NONE)
      data_obj.data = vintf.prdata;
      data_obj.slv_err = vintf.slv_err;
   endtask


   task reset();
      @(negedge vintf.rst_n);
      `uvm_info("DRIVER", $sformatf("Reset detected "), UVM_NONE)

   endtask //reset


endclass

