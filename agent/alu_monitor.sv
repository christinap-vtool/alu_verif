class alu_monitor extends uvm_monitor;
   `uvm_component_utils(alu_monitor)
   virtual interfc vintf;
   apb_transaction  tr_item;
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


   virtual task run_phase(uvm_phase phase);
      forever begin
         @(posedge vintf.clk);
         if(!vintf.rst_n) begin
            monitor_reset();
         end
         else if (vintf.rst_n ) begin
            wr_rd_task();
            //ap_monitor.write (tr_item);

         end
         else begin
            `uvm_error("","monitor cannot capture if there is a reset, a write or an read operation\n");
         end
      end
   endtask

   task monitor_reset();
      //TODO CHECK THE RESET. maybe shoud add as a define write, read and the reset operation
      `uvm_info("MONITOR", "SYSTEM RESET DETECTED", UVM_NONE)
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
         `uvm_info("MONITOR", $sformatf("DATA READ WRITE addr:%0d data:%0d slverr:%0d",tr_item.addr ,tr_item.data,tr_item.slv_err), UVM_NONE); 
         wait (vintf.penable == 0 && vintf.psel ==0);

         ap_monitor.write (tr_item);



      end
      
   endtask
endclass