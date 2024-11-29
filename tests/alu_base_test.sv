class alu_base_test extends alu_testbase;
   `uvm_component_utils(alu_base_test)

   function new(string name="alu_base_test", uvm_component parent);
      super.new(name,parent);
   endfunction
   apb_seq seq;



   //alu_env env;
   reg_block   m_ral_model; //register model

   function void build_phase(uvm_phase phase);
      super.build_phase(phase); 

      seq = apb_seq::type_id::create("seq");


   endfunction

   task run_phase(uvm_phase phase);
      super.run_phase(phase);
      phase.raise_objection(this);
      `uvm_info(get_name(), "START TEST", UVM_NONE)
      #10;

      //randomize(seq);
      seq.randomize() with{wr_trans==5;};

      seq.start(env.fifo_vr_sqr);

      #100ns;
      phase.drop_objection(this);

   endtask
endclass