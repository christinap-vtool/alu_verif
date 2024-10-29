#!/bin/tcsh

# Array of test names
set TESTNAMES = (alu_base_test alu_empty_fifo_out_test alu_full_fifo_in_test alu_read_from_write_test alu_reset_test alu_write_to_read_reg apb_address_test)
#set TESTNAMES = (alu_full_fifo_in_test )

# Number of times to run each test
set N = 20


# Iterate over test names
foreach TESTNAME ($TESTNAMES)
   # Inner loop to run each test N times
   foreach i (`seq 1 $N`)
      # Run the command with the current test name and seed
      echo "\n\nRunning test: $TESTNAME, seed: $i\n\n"
      xrun -timescale 1ns/1ns -sysv -access +rw -uvm -coverage ALL -covoverwrite -seed RANDOM -f compile_files.f -uvmhome CDNS-1.2 \
      top_tb.sv \
      +UVM_VERBOSITY=UVM_LOW\
      +UVM_TESTNAME=$TESTNAME -l logs/${TESTNAME}_$i.log \
      +DUMPNAME="${TESTNAME}_$i.vcd" -covtest ${TESTNAME}_$i

   end

end
