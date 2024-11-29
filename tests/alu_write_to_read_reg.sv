//This test exams the occation that a user tries to write in a Read Only register. 
//The only RO registers in this design are the Result register and the Monitor Register.
//This action will cause a slave error response.
class alu_write_to_read_reg extends alu_testbase;
   `uvm_component_utils(alu_write_to_read_reg)

   function new(string name="alu_write_to_read_reg", uvm_component parent);
      super.new(name,parent);
   endfunction

   write_to_read_reg seq1;
   reg_block   m_ral_model; //register model

   function void build_phase(uvm_phase phase);
      super.build_phase(phase); 
      seq1 = write_to_read_reg::type_id::create("seq1");
   endfunction

   task run_phase(uvm_phase phase);
      super.run_phase(phase);
      phase.raise_objection(this);
      `uvm_info(get_name(), "START TEST", UVM_NONE)
      #10;

      seq1.randomize() with{wr_trans==1;};

      seq1.start(env.fifo_vr_sqr);

      #100ns;
      phase.drop_objection(this);

   endtask
endclass