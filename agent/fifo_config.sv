`ifndef FIFO_CONFIG_SV
`define FIFO_CONFIG_SV

class fifo_config extends uvm_object;
   `uvm_object_utils(fifo_config)
   virtual interfc vintf;
   uvm_active_passive_enum  is_active = UVM_ACTIVE;
   wr_rd_type              cfg_wr_rd;

   function new(string name = "fifo_config"); 
   super.new(name);
   endfunction

endclass

`endif//FIFO_CONFIG_SV



