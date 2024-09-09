class alu_monitor extends uvm_monitor;
   `uvm_component_utils(alu_monitor)
   virtual interfc vintf;
   apb_transaction  tr_item;    //todo i'm not sure if we need this 
   fifo_config fifo_conf; 
   bit rw;

   //port
   uvm_analysis_port #(apb_transaction) ap_monitor;

   function new(string name, uvm_component parent);
      super.new(name,parent);
   endfunction

   function void build_phase(uvm_phase phase);
      super.build_phase(phase);
      tr_item =apb_transaction::type_id::create("tr_item");
      //create an instance of the analysis port
      ap_monitor = new("ap_monitor", this);
      //get interface reference from config database
      if(!uvm_config_db#(virtual interfc) :: get(this,"","interfc",vintf)) begin
         `uvm_error("","uvm_get_config interface failed\n");
      end

   endfunction

      /*
   //previous implementation. this can pass the compile

      virtual task run_phase (uvm_phase phase);
         `uvm_info(get_type_name(), "run_phase", UVM_HIGH)
         forever begin
               //todo ia active low reset check the below code for the reset
               #1ns;
               if (vintf.rst_n == 1) begin
                  @(negedge vintf.rst_n);
               end

               @(posedge vintf.rst_n);
               `uvm_info(get_type_name(), "got through reset", UVM_NONE)

               fork
                  begin
                     
                     if (rw == 1) begin 
                           wr_data();
                     end
                     else begin
                           rd_data();
                     end
                  end
                  //this begin end will quit when reset appears and kill every begin-end inside the fork
                  begin
                     monitor_reset();
                  end
               join
         end
      endtask
   */

   virtual task run_phase(uvm_phase phase);
      forever begin
         @(posedge vintf.clk);
         if(!vintf.rst_n) begin
            monitor_reset();
         end
         else if (vintf.rst_n && vintf.pwrite) begin
            wr_data();
         end
         else if(vintf.rst_n && !vintf.pwrite) begin
            rd_data();
         end 
         else begin
            `uvm_error("","monitor cannot capture if there is a reset, a write or an read operation\n");
         end
      end
   endtask
   task wr_data();
      @(negedge vintf.ready);
      tr_item.op = write;
      tr_item.data = vintf.pwdata;
      tr_item.addr = vintf.paddr;
      tr_item.slv_err = vintf.slv_err;
      `uvm_info("MONITOR", $sformatf("DATA WRITE addr:%0d data:%0d slverr:%0d",tr_item.addr ,tr_item.data,tr_item.slv_err), UVM_NONE); 
      ap_monitor.write (tr_item);
   endtask
   task rd_data();
      @(negedge vintf.ready);
      tr_item.op = read;
      tr_item.data = vintf.pwdata;
      tr_item.addr = vintf.paddr;
      tr_item.slv_err = vintf.slv_err;
      `uvm_info("MONITOR", $sformatf("DATA READ addr:%0d data:%0d slverr:%0d",tr_item.addr ,tr_item.data,tr_item.slv_err), UVM_NONE); 
      ap_monitor.write (tr_item);
   endtask
   task monitor_reset();
      //TODO CHECK THE RESET. maybe shoud add as a define write, read and the reset operation
      `uvm_info("MONITOR", "SYSTEM RESET DETECTED", UVM_NONE);
   endtask

    // task wr_data();
    //     forever begin
    //        @(posedge vintf.clk);
    //        if(vintf.psel & vintf.penable & vintf.rst_n) begin
    //             tr_item.addr = vintf.paddr;
    //             tr_item.data = vintf.pwdata;
    //             tr_item.write = vintf.pwrite;
    //             ap_monitor.write (tr_item);
    //        end

    //     end
    // endtask

    // task rd_data();
    //     forever begin
    //         @(posedge vintf.clk);
    //         if(vintf.psel & vintf.penable & vintf.rst_n) begin
    //             tr_item.addr = vintf.paddr;
    //             tr_item.data = vintf.prdata;
    //             tr_item.write = vintf.pwrite;
    //             //todo maybe I have to add 2 signals. full and empty. but the design top doesn't have these 2 signals.
    //             ap_monitor.write (tr_item);
    //        end
    //     end
    // endtask

    // task monitor_reset();
    // //todo create an ap for the reset and fill in the following part of code
    //     // @(negedge vintf.rst_n);

    //     // // send reset bit to scoreboard via reset analysis port
    //     // reset_analysis_port.write(1);
    //     // `uvm_info(get_type_name(), "RESET CAME!", UVM_NONE)

    //     // @(posedge vintf.rst_n);
    //     // reset_analysis_port.write(0);
    // endtask
    
endclass