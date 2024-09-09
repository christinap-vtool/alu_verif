class control_reg extends uvm_reg;

   `uvm_object_utils(control_reg)

   rand uvm_reg_field start;
   rand uvm_reg_field operation;
   rand uvm_reg_field reserved;
   rand uvm_reg_field id;

   function new (string name ="control_reg");
      super.new(name, 16, UVM_NO_COVERAGE);
   endfunction

   function void build;
      start = uvm_reg_field::type_id::create("start");

      start.configure(
         .parent(this),
         .size(1),
         .lsb_pos(0),
         .access("WO"),
         .volatile(0),
         .reset(1'h0),
         .has_reset(1),
         .is_rand(1),
         .individually_accessible(1)
      );
      operation = uvm_reg_field::type_id::create("operation");

      operation.configure(
         .parent(this),
         .size(2),
         .lsb_pos(1),
         .access("WO"),
         .volatile(0),
         .reset(2'h0),
         .has_reset(1),
         .is_rand(1),
         .individually_accessible(1)
      );
      reserved = uvm_reg_field::type_id::create("reserved");
         reserved.configure(
         .parent(this),
         .size(5),
         .lsb_pos(3),
         .access("RO"),
         .volatile(0),
         .reset(8'h0),
         .has_reset(1),
         .is_rand(1),
         .individually_accessible(1)
      );

      id = uvm_reg_field::type_id::create("id");

      id.configure(
         .parent(this),
         .size(8),
         .lsb_pos(8),
         .access("WO"),
         .volatile(0),
         .reset(8'h0),
         .has_reset(1),
         .is_rand(1),
         .individually_accessible(1)
      );

   endfunction


endclass

class data0_reg extends uvm_reg;
   `uvm_object_utils(data0_reg)

   rand uvm_reg_field data0;

   function new (string name ="control_reg");
      super.new(name, 16, UVM_NO_COVERAGE);
   endfunction

   function void build;
      data0 = uvm_reg_field::type_id::create("data0");
      data0.configure(
         .parent(this),
         .size(16),
         .lsb_pos(0),
         .access("WO"),
         .volatile(0),
         .reset(16'h0),
         .has_reset(1),
         .is_rand(1),
         .individually_accessible(1)

      );

   endfunction


endclass

class data1_reg extends uvm_reg;
   `uvm_object_utils(data1_reg)
   rand uvm_reg_field data1;

   function new (string name ="data1_reg");
      super.new(name, 16, UVM_NO_COVERAGE);
   endfunction

   function void build;
      data1 = uvm_reg_field::type_id::create("data1");
      data1.configure(
      .parent(this),
      .size(16),
      .lsb_pos(0),
      .access("WO"),
      .volatile(0),
      .reset(16'h0),
      .has_reset(1),
      .is_rand(1),
      .individually_accessible(1)
      );
   endfunction


endclass

class result_reg extends uvm_reg;
   `uvm_object_utils(result_reg)

   rand uvm_reg_field result;

   function new (string name ="result_reg");
      super.new(name, 25, UVM_NO_COVERAGE);
   endfunction

   function void build;
      result = uvm_reg_field::type_id::create("result");
      result.configure(
      .parent(this),
      .size(25),
      .lsb_pos(0),
      .access("RO"),
      .volatile(0),
      .reset(16'h0),
      .has_reset(1),
      .is_rand(1),
      .individually_accessible(1)

      );

   endfunction


endclass


class monitor_reg extends uvm_reg;
   `uvm_object_utils(monitor_reg)

   rand uvm_reg_field monitor;

   function new (string name ="monitor_reg");
      super.new(name, 25, UVM_NO_COVERAGE);
   endfunction

   function void build;
      monitor = uvm_reg_field::type_id::create("monitor");
      monitor.configure(
      .parent(this),
      .size(25),
      .lsb_pos(0),
      .access("RO"),
      .volatile(0),
      .reset(16'h0),
      .has_reset(1),
      .is_rand(1),
      .individually_accessible(1)
      );
   endfunction


endclass







// class reg_block extends uvm_reg_block;
//     `uvm_component_utils(reg_block)

//     rand control_reg   m_control_reg;
//     rand data0_reg     m_data0_reg;   
//     rand data1_reg     m_data1_reg;
//     rand result_reg    m_result_reg;
//     rand monitor_reg   m_monitor_reg;
//     //tododeclare the map
//     uvm_reg_map        

//     function new(string name ="reg_block");
//         super.new(name, UVM_NO_COVERAGE);
//     endfunction

//     virtual function void build();
//         //create an instance for every register 
//         this.default_map = create_map("", 0, 4, UVM_LITTLE_ENDIAN, 0);   //TODO CHECK WHAT IS THIS???
//         this.m_control_reg = control_reg::type_id::create ("m_control_reg", , get_full_name());
//         this.m_data0_reg = data0_reg::type_id::create ("m_data0_reg", , get_full_name());
//         this.m_data1_reg = data1_reg::type_id::create ("m_data1_reg", , get_full_name());
//         this.m_result_reg = result_reg::type_id::create ("m_result_reg", , get_full_name());
//         this.m_monitor_reg = monitor_reg::type_id::create ("m_monitor_reg", , get_full_name());

//         //configure every register instance
//         this.m_control_reg.configure (this, null, "");
//         this.m_data0_reg.configure (this, null, "");
//         this.m_data1_reg.configure (this, null, "");
//         this.m_result_reg.configure (this, null, "");
//         this.m_monitor_reg.configure (this, null, "");

//         //call the build() function to build all register fields within each register
//         this.m_control_reg.build();
//         this.m_data0_reg.build();
//         this.m_data1_reg.build();
//         this.m_result_reg.build();
//         this.m_monitor_reg.build();

//         //add these registers to the default map
//         this.default_map.add_reg (this.m_control_reg, `UVM_REG_ADDR_WIDTH'h0, "WO", 0);
//         this.default_map.add_reg (this.m_data0_reg, `UVM_REG_ADDR_WIDTH'h1, "WO", 0);
//         this.default_map.add_reg (this.m_data1_reg, `UVM_REG_ADDR_WIDTH'h2, "WO", 0);
//         this.default_map.add_reg (this.m_result_reg, `UVM_REG_ADDR_WIDTH'h3, "RO", 0);
//         this.default_map.add_reg (this.m_monitor_reg, `UVM_REG_ADDR_WIDTH'h4, "RO", 0);

//         //todo check the following --> lock and autopredict
//         default_map.set_auto_predict(1);
//         lock_model();


//     endfunction
// endclass



class reg_block extends uvm_reg_block;
   `uvm_object_utils(reg_block)

   rand control_reg   m_control_reg;
   rand data0_reg     m_data0_reg;   
   rand data1_reg     m_data1_reg;
   rand result_reg    m_result_reg;
   rand monitor_reg   m_monitor_reg;
   //tododeclare the map
   uvm_reg_map         reg_map;      

   function new(string name ="reg_block");
      super.new(.name(name), .has_coverage(UVM_NO_COVERAGE));
   endfunction

   virtual function void build();
      //create an instance for every register 
      reg_map = create_map("", 0, 4, UVM_LITTLE_ENDIAN, 0);   //TODO CHECK WHAT IS THIS???
      m_control_reg = control_reg::type_id::create ("m_control_reg");
      m_data0_reg = data0_reg::type_id::create ("m_data0_reg");
      m_data1_reg = data1_reg::type_id::create ("m_data1_reg");
      m_result_reg = result_reg::type_id::create ("m_result_reg");
      m_monitor_reg = monitor_reg::type_id::create ("m_monitor_reg");

      //configure every register instance
      m_control_reg.configure (this, null, "");
      m_data0_reg.configure (this, null, "");
      m_data1_reg.configure (this, null, "");
      m_result_reg.configure (this, null, "");
      m_monitor_reg.configure (this, null, "");

      //call the build() function to build all register fields within each register
      m_control_reg.build();
      m_data0_reg.build();
      m_data1_reg.build();
      m_result_reg.build();
      m_monitor_reg.build();

      //add these registers to the default map

      reg_map.add_reg (m_control_reg, `UVM_REG_ADDR_WIDTH'h0, "WO", 0);
      reg_map.add_reg (m_data0_reg, `UVM_REG_ADDR_WIDTH'h1, "WO", 0);
      reg_map.add_reg (m_data1_reg, `UVM_REG_ADDR_WIDTH'h2, "WO", 0);
      reg_map.add_reg (m_result_reg, `UVM_REG_ADDR_WIDTH'h3, "RO", 0);
      reg_map.add_reg (m_monitor_reg, `UVM_REG_ADDR_WIDTH'h4, "RO", 0);

      //todo check the following --> lock and autopredict
      //default_map.set_auto_predict(1);
      default_map.set_check_on_read(1);
      lock_model();

   endfunction
endclass

