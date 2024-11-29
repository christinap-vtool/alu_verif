class control_reg extends uvm_reg;

    `uvm_object_utils(control_reg)

    rand uvm_reg_field start;
    rand uvm_reg_field operation;
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

        start.configure(
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

        id = = uvm_reg_field::type_id::create("id");

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
        dat0.configure(
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
        dat1.configure(
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
        super.new(name, 16, UVM_NO_COVERAGE);
    endfunction

    function void build;
        result = uvm_reg_field::type_id::create("result");
        result.configure(
            .parent(this),
            .size(16),
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
        super.new(name, 16, UVM_NO_COVERAGE);
    endfunction

    function void build;
        monitor = uvm_reg_field::type_id::create("monitor");
        monitor.configure(
            .parent(this),
            .size(16),
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




