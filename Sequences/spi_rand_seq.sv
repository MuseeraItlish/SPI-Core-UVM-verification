`ifndef SPI_RANDOM_SEQUENCE_SV
`define SPI_RANDOM_SEQUENCE_SV

class spi_random_sequence extends spi_base_sequence;

    `uvm_object_utils(spi_random_sequence)

    function new(string name = "spi_random_sequence");
        super.new(name);
    endfunction

    virtual task body();

        bit [2:0] addr;
        bit [7:0] data;

        super.body();

        `uvm_info(get_type_name(),
                  "Starting Random Register Test",
                  UVM_LOW)

        repeat(100)
        begin

            // Generate a valid writable register
            case($urandom_range(0,2))
                0 : addr = 3'b000;   // SPCR
                1 : addr = 3'b011;   // SPER
                2 : addr = 3'b100;   // SS Register
            endcase

            // Generate random data
            data = $urandom;

            //---------------------------------------
            // WRITE
            //---------------------------------------

            req = spi_transaction::type_id::create("wr_req");

            start_item(req);

            req.write      = 1;
            req.address    = addr;
            req.write_data = data;

            finish_item(req);

            //---------------------------------------
            // READ
            //---------------------------------------

            req = spi_transaction::type_id::create("rd_req");

            start_item(req);

            req.write      = 0;
            req.address    = addr;
            req.write_data = 8'h00;

            finish_item(req);

        end

    endtask

endclass

`endif