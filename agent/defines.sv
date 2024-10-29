`define DATA_WIDTH 16
`define DATA_SIZE 16
`define MUL_DATA_SIZE 8
`define FIFO_IN_DEPTH 4
`define FIFO_OUT_DEPTH 4
`define APB_BUS_SIZE 32
`define REG_NUMBER 5
`define ADDR_W 2


typedef enum {read, write} wr_rd_type;
//for coverage
typedef enum {write_to_read_register,
              read_from_write_register,
              no_available_addr,
              read_from_empty_fifo_out,
              write_to_full_fifo_in,
              false_operation
} cause_of_slv_err;

typedef enum  { addition,
               multiplication
} operation_type;


