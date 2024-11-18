class alu_monitor extends uvm_monitor;
   `uvm_component_utils(alu_monitor)
   virtual interfc vintf;
   apb_transaction  tr_item;
   fifo_config fifo_conf;

   //port
   uvm_analysis_port #(apb_transaction) ap_monitor;
   uvm_analysis_port #(bit) reset_port;

   function new(string name, uvm_component parent);
      super.new(name,parent);
   endfunction

   function void build_phase(uvm_phase phase);
      super.build_phase(phase);
      tr_item =apb_transaction::type_id::create("tr_item");
      //create an instance of the analysis port
      ap_monitor = new("ap_monitor", this);
      reset_port = new("reset_port",this);
      //get interface reference from config database
      if(!uvm_config_db#(virtual interfc) :: get(this,"","interfc",vintf)) begin
         `uvm_error("","uvm_get_config interface failed\n");
      end
   endfunction


   virtual task run_phase(uvm_phase phase);
      forever begin
         @(posedge vintf.clk);
         if(!vintf.presetn) begin
            @(posedge vintf.presetn);
         end
         begin
            fork
               wr_rd_task();
               monitor_reset();
            join_any
            disable fork;
            `uvm_info("MONITOR", "AFTER", UVM_HIGH)
         end
      end
   endtask

   task monitor_reset();
      @(negedge vintf.presetn);
      `uvm_info("MONITOR", "SYSTEM RESET DETECTED", UVM_NONE)
      reset_port.write(1);
   endtask

   task wr_rd_task();
      forever
      begin
         wait (vintf.psel==1 && vintf.penable==1 && vintf.ready ==1);
         @(negedge vintf.clk);
         if(vintf.pwrite == 0) begin
            tr_item.op = read;
            tr_item.data = vintf.prdata;
         end
         else begin
            tr_item.op = write;
            tr_item.data = vintf.pwdata;
         end
         tr_item.addr = vintf.paddr;
         tr_item.slv_err = vintf.slv_err;
         `uvm_info("MONITOR", $sformatf("DATA READ WRITE addr:%0d data:%0d slverr:%0d",tr_item.addr ,tr_item.data,tr_item.slv_err), UVM_HIGH);
         wait (vintf.penable == 0 && vintf.psel ==0);
         ap_monitor.write (tr_item);
      end
   endtask
endclass