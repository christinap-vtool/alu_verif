//This test exams the occation that a user requests to read a result without having given operants.
//The master tries to read a result from the Result register, but FIFO_OUT is empty.
//This action will cause a slave error response. the occation.

class alu_empty_fifo_out_test extends alu_testbase;
   `uvm_component_utils(alu_empty_fifo_out_test)
   function new(string name="alu_empty_fifo_out_test", uvm_component parent);
      super.new(name,parent);
   endfunction

   alu_fifo_out_empty_seq seq;
   reg_block   m_ral_model; //register model

   function void build_phase(uvm_phase phase);
      super.build_phase(phase);
      seq = alu_fifo_out_empty_seq::type_id::create("seq");
   endfunction

   task run_phase(uvm_phase phase);
      super.run_phase(phase);
      phase.raise_objection(this);
      `uvm_info(get_name(), "START TEST", UVM_NONE)
      #10;
      randomize(seq);
      seq.start(env.fifo_vr_sqr);
      #100ns;
      phase.drop_objection(this);
   endtask
endclass