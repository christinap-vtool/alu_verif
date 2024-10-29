`include "fifo_config.sv" 
class alu_testbase extends uvm_test;
   `uvm_component_utils(alu_testbase)
   alu_env          env;
   alu_env_config   env_cfg;
   alu_agent        agent;
   fifo_config      conf; 
   fifo_config	   read_agent;

   function new (string name="alu_testbase",uvm_component parent = null);    
      super.new(name,parent);
      conf = new("conf");
   endfunction

   function void build_phase(uvm_phase phase);
      super.build_phase(phase); 

      conf.cfg_wr_rd  = write;
      conf.is_active = UVM_ACTIVE;

      //make each cfg available to its respective agent
      uvm_config_db#(fifo_config)::set(this,"*.agent","fifo_config",conf);

      env_cfg = alu_env_config ::type_id::create("env_cfg");
      //instantiate fifo_env and fifo_agent_config
      env = alu_env::type_id::create("env",this);
   endfunction:build_phase 

   task run_phase(uvm_phase phase);
      super.run_phase(phase);
      env.fifo_vr_sqr.vintf.rst_n = 1;
      `uvm_info("testbase", $sformatf("run_phase testbase"), UVM_NONE)
   endtask

   //by this phase is all set up so its good to just print the topology for debug
   virtual function void end_of_elaboration_phase(uvm_phase phase);
      uvm_top.print_topology();
   endfunction

endclass:alu_testbase

