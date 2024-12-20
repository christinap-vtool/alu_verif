//The master tries to send new data to be computed, but FIFO_IN is full.
//This action will cause a slave error response.
class alu_full_fifo_in_test extends alu_testbase;
   `uvm_component_utils(alu_full_fifo_in_test)

   function new(string name="alu_full_fifo_in_test", uvm_component parent);
      super.new(name,parent);
   endfunction
   alu_fifo_in_full_seq seq;

   reg_block   m_ral_model; //register model

   function void build_phase(uvm_phase phase);
      super.build_phase(phase); 

      seq = alu_fifo_in_full_seq::type_id::create("seq");
   endfunction

   task run_phase(uvm_phase phase);
      super.run_phase(phase);
      phase.raise_objection(this);
      `uvm_info(get_name(), "START TEST", UVM_NONE)
      #10;

      seq.randomize() with{wr_trans==20; rd_trans==8;};

      seq.start(env.fifo_vr_sqr);

      //#100ns;
      phase.drop_objection(this);

   endtask
endclass