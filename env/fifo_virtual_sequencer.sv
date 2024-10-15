class fifo_virtual_sequencer extends uvm_sequencer;
   `uvm_component_utils (fifo_virtual_sequencer)
   //fifo_sequencer write_seqr;
   //fifo_sequencer read_seqr;
   fifo_sequencer apb_seqr;
   virtual interfc vintf;
   function new(string name = "fifo_virtual_sequencer", uvm_component parent);
      super.new(name,parent);
   endfunction

   function void build_phase(uvm_phase phase);
      super.build_phase(phase);
      if(!uvm_config_db#(virtual interfc)::get(this,"","interfc",vintf))begin
         `uvm_error("","uvm_get_config interface failed\n");
      end
   endfunction

endclass


