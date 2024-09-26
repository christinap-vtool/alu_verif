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

      apb_transaction pkt = apb_transaction::type_id::create("pkt"); 
      pkt.write =(rw.kind == UVM_WRITE) ? 1:0;
      pkt.op =(rw.kind == UVM_WRITE) ? 1:0;
      pkt.addr = rw.addr;
      pkt.data =rw.data;
      `uvm_info("adapter", $sformatf("reg2bus addr=0x%0h data=0x%0h kind=%s", pkt.addr, pkt.data, rw.kind.name), UVM_DEBUG)
      return pkt;

   endfunction

   virtual function void bus2reg (uvm_sequence_item bus_item, ref uvm_reg_bus_op rw);
      apb_transaction pkt;
      if(! $cast (pkt, bus_item)) begin
      `uvm_fatal ("adapter", "failed to cast bus_item to pkt ")
      end

      //rw.kind = pkt.write ? UVM_WRITE : UVM_READ;
      rw.kind = pkt.op ? UVM_WRITE : UVM_READ;
      rw.addr = pkt.addr;
      rw.data = pkt.data;
      rw.status = UVM_IS_OK; //APB does not support slave response
      `uvm_info ("adapter", $sformatf("bus2reg : pkt.write=%s ", pkt.op), UVM_NONE)

      `uvm_info ("adapter", $sformatf("bus2reg : addr=0x%0h data=0x%0h kind=%s status=%s", rw.addr, rw.data, rw.kind.name(), rw.status.name()), UVM_NONE)

   endfunction

endclass

