// typedef struct {
//     uvm_access_e   kind;    //Acceess type: UVM_READ/UVM_WRITE
//     uvm_reg_addr_t addr;   //Bus address, default 64 bits
//     uvm_reg_data_t data;   //Read/Write data, default 64 bits
//     int            n_bits; // number of bits being tranferred
//     uvm_reg_byte_en byte_en; //byte enable
//     uvm_status_e    status; //result of transaction: UVM_IS_OK, UVM_HAS_X, UVM_NOT_OK
    
// }uvm_reg_bus_op;


//class reg2apb_adapter extends uvm_reg_adapter;
class adapter extends uvm_reg_adapter;

   `uvm_object_utils (adapter)
   //set default values for the two variables based on bus protocol
   //apb does not support either, so both turned off

   function new(string name="");
      super.new(name);
      supports_byte_enable = 0;
      provides_responses = 0;
   endfunction

   virtual function uvm_sequence_item reg2bus (const ref uvm_reg_bus_op rw);
      // bus_pkt pkt = bus_pkt::type_id::create("pkt"); //todo what is the bus pkt?? where has this been declared?   => to diko mou sequence item allaxeto!!
      // apb_transaction pkt;
      // pkt = apb_transaction::type_id::create("pkt"); 

      apb_transaction pkt = apb_transaction::type_id::create("pkt"); 

      pkt.write =(rw.kind == UVM_WRITE) ? 1:0;
      pkt.addr = rw.addr;
      pkt.data =rw.data;
      `uvm_info("adapter", $sformatf("reg2bus addr=0x%0h data=0x%0h kind=%s", pkt.addr, pkt.data, rw.kind.name), UVM_DEBUG)
      return pkt;

   endfunction

   virtual function void bus2reg (uvm_sequence_item bus_item, ref uvm_reg_bus_op rw);
      //bus_pkt pkt;   //todo==> oxi bus_pkt alla to diko mou sequence item
      apb_transaction pkt;
      if(! $cast (pkt, bus_item)) begin
      `uvm_fatal ("adapter", "failed to cast bus_item to pkt ")
      end

      rw.kind = pkt.write ? UVM_WRITE : UVM_READ;
      rw.addr = pkt.addr;
      rw.data = pkt.data;
      rw.status = UVM_IS_OK; //APB does not support slave response
      `uvm_info ("adapter", $sformatf("bus2reg : pkt.write=%0h ", pkt.write), UVM_NONE)

      `uvm_info ("adapter", $sformatf("bus2reg : addr=0x%0h data=0x%0h kind=%s status=%s", rw.addr, rw.data, rw.kind.name(), rw.status.name()), UVM_NONE)

   endfunction

endclass


//predictor
// class uvm_reg_predictor #(type apb_transaction) extends uvm_component;
//     `uvm_component_param_utils(uvm_reg_predictor#(apb_transaction))

//     uvm_analysis_imp #(apb_transaction, uvm_reg_predictor, #(apb_transaction)) bus_in;
//     uvm_reg_map map;
//     uvm_reg_adapter adapter;
//     reg_block   m_ral_model; //register model
//     //alu_agent  agent;
    
//typedef uvm_reg_predictor#(apb_transaction)  apb_predictor;   //map apb tx to register in model

//typedef uvm_reg_predictor#(apb_transaction)   m_apb_predictor;

//     virtual function void build_phase(uvm_phase phase);
//         super.build_phase(phase);
//         m_apb_predictor = uvm_reg_predictor#(apb_transaction) :: type_id::create("m_apb_predictor", this);
      
//     endfunction

//     virtual function void connect_phase (uvm_phase phase);
//         super.connect_phase(phase);
//         //provide register map to the predictor / assinging map handle
//         m_apb_predictor.map = m_ral_model.default_map;
//         //provide an adapter to help convert bus packet into register item  / assigning adapter handle
//         m_apb_predictor.adapter = adapter;
//         //connect analysis port of target monitor to analysis implementation of predictor
//         //m_apb_agent.ap.connect(m_apb_predictor.bus_in);
//         //agent.monitor.ap_.connect(m_apb_predictor.bus_in);  //todo check if here i need to connect them
//     endfunction

// endclass
