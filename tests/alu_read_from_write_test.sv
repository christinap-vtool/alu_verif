class alu_read_from_write_test extends alu_testbase;
   `uvm_component_utils(alu_read_from_write_test)

   function new(string name="alu_read_from_write_test", uvm_component parent);
      super.new(name,parent);
   endfunction
   //write_to_read_reg seq;
   read_from_write_reg seq1;


   //alu_env env;
   reg_block   m_ral_model; //register model

   function void build_phase(uvm_phase phase);
      super.build_phase(phase); 
      seq1 = read_from_write_reg::type_id::create("seq1");

   endfunction

   task run_phase(uvm_phase phase);
      super.run_phase(phase);
      phase.raise_objection(this);
      `uvm_info(get_name(), "START TEST", UVM_NONE)
      #10;

      //randomize(seq);
      seq1.randomize() with{wr_trans==1;};

      seq1.start(env.fifo_vr_sqr);

      #100ns;
      phase.drop_objection(this);

   endtask
endclass