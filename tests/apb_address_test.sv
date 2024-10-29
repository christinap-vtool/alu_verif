class apb_address_test extends alu_testbase;
   `uvm_component_utils(apb_address_test)
   rand int num_of_trans;
   apb_write_read_sequence seq_addr;


   function new(string name="apb_address_test", uvm_component parent);
      super.new(name,parent);
   endfunction

   function void build_phase(uvm_phase phase);
      super.build_phase(phase); 
      seq_addr = apb_write_read_sequence::type_id::create("seq_addr");
  endfunction

   task run_phase(uvm_phase phase);
      super.run_phase(phase);
      phase.raise_objection(this);
      num_of_trans =  $urandom_range(1,9);
      repeat (num_of_trans) begin
         `uvm_info(get_name(),"START TEST",UVM_NONE)
         randomize(seq_addr);
         seq_addr.start(env.fifo_vr_sqr.apb_seqr);
         phase.drop_objection(this);
      end

   endtask
endclass