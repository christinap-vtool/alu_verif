class alu_env_config extends uvm_object;
   `uvm_object_utils(alu_env_config)

   virtual interfc vintf;
   reg_block   m_ral_model;
   uvm_active_passive_enum  is_active = UVM_ACTIVE;

   function new(string name = "");
      super.new(name); 
   endfunction

endclass