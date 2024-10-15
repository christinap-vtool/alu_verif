class alu_env extends uvm_env;
   `uvm_component_utils(alu_env)
   // declare and build verification components
   alu_agent agent;
   alu_scoreboard scbd;
   fifo_virtual_sequencer fifo_vr_sqr;
   reg_block   m_ral_model; //register model
   adapter   m_apb_adapter; //convert reg tx <-> bus type packets
   uvm_reg_predictor #(apb_transaction)  m_apb_predictor;   //map apb tx to register in model
   //apb_predictor   m_apb_predictor;   //map apb tx to register in model

   alu_env_config  env_cfg;

   function new (string name = "alu_env",uvm_component parent = null);
      super.new(name, parent);
   endfunction

   function void build_phase(uvm_phase phase);
      super.build_phase (phase);

      m_ral_model = reg_block::type_id::create("m_ral_model",this);
      agent = alu_agent :: type_id ::create("agent", this);
      scbd = alu_scoreboard :: type_id ::create("scbd", this);
      fifo_vr_sqr = fifo_virtual_sequencer :: type_id :: create("fifo_vr_sqr",this);
      m_apb_predictor = uvm_reg_predictor#(apb_transaction)::type_id::create("m_apb_predictor",  this);
      m_ral_model.build();
      m_ral_model.lock_model ();   //a register model has to be locked via invocation of its lock() function in order to prevent any other testbench component or part from modifying the structure or adding registers to it.  
      uvm_config_db #(reg_block):: set(null, "top_tb", "m_ral_model", m_ral_model);
      m_apb_adapter = adapter::type_id::create("m_apb_adapter",,get_full_name());
   endfunction

   function void connect_phase(uvm_phase phase);
      super.connect_phase (phase);
      agent.monitor.ap_monitor.connect(scbd.ap_imp);
      // m_ral_model.reg_map.set_sequencer(.sequencer(agent.sequencer));
      m_ral_model.reg_map.set_sequencer(.sequencer(agent.sequencer), .adapter(m_apb_adapter)); 
      m_ral_model.reg_map.set_base_addr(0); 

      fifo_vr_sqr.apb_seqr = agent.sequencer;

      //connect analysis ports from agent to the .scoreboard

      m_apb_predictor.map = m_ral_model.reg_map;

      //provide an adapter to hepl convert apb packet into register item

      m_apb_predictor.adapter = m_apb_adapter;
      scbd.m_ral_model = m_ral_model;

      agent.monitor.ap_monitor.connect(m_apb_predictor.bus_in);
      m_ral_model.reg_map.set_auto_predict(0);

   endfunction
endclass