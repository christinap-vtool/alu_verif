class alu_agent extends uvm_agent;
   `uvm_component_utils (alu_agent)
   //create handles to all agent components like driver monitor etc

   fifo_config    conf;
   alu_driver     driver;
   alu_monitor    monitor;
   fifo_sequencer sequencer;
   adapter        m_adapter;

   function new(string name, uvm_component parent);
      super.new(name,parent);
   endfunction

   //instantiate and build components
   virtual function void build_phase (uvm_phase phase);
      super.build_phase(phase);
      conf = fifo_config :: type_id ::create ("conf",this);
      if(!uvm_config_db#(fifo_config) :: get(this,"","fifo_config", conf))
         `uvm_error(get_type_name(), "Unable to get top_config")

      if (get_is_active() == UVM_ACTIVE) begin
         driver = alu_driver :: type_id :: create ("driver", this);
      end

      sequencer = fifo_sequencer :: type_id ::create ("sequencer", this);

      monitor = alu_monitor :: type_id :: create("monitor", this);
      m_adapter = adapter :: type_id :: create("m_adapter", this);

   endfunction

   //connect agent components together
   virtual function void connect_phase (uvm_phase phase);
      super.connect_phase(phase);
      if (get_is_active() == UVM_ACTIVE) begin
         driver.seq_item_port.connect(sequencer.seq_item_export);
      end
   endfunction

endclass