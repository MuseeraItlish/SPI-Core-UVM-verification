`ifndef SPI_REGISTER_SEQUENCE_SV
`define SPI_REGISTER_SEQUENCE_SV

class spi_register_sequence extends spi_base_sequence;

    `uvm_object_utils(spi_register_sequence)

    function new(string name = "spi_register_sequence");
        super.new(name);
    endfunction

    virtual task body();

        super.body();

        `uvm_info(get_type_name(),
                  "Running Register Write/Read Sequence",
                  UVM_LOW)

        //-------------------------------------------------
        // Write 0xFF to SPCR
        //-------------------------------------------------

        req = spi_transaction::type_id::create("wr_spcr");

        start_item(req);

        req.write      = 1;
        req.address    = 3'b000;      // SPCR
        req.write_data = 8'hFF;

        finish_item(req);

        //-------------------------------------------------
        // Read SPCR back
        //-------------------------------------------------

        req = spi_transaction::type_id::create("rd_spcr");

        start_item(req);

        req.write      = 0;
        req.address    = 3'b000;
        req.write_data = 8'h00;

        finish_item(req);

        //-------------------------------------------------
        // Write 0x55 to SPER
        //-------------------------------------------------

        req = spi_transaction::type_id::create("wr_sper");

        start_item(req);

        req.write      = 1;
        req.address    = 3'b011;      // SPER
        req.write_data = 8'h55;

        finish_item(req);

        //-------------------------------------------------
        // Read SPER
        //-------------------------------------------------

        req = spi_transaction::type_id::create("rd_sper");

        start_item(req);

        req.write      = 0;
        req.address    = 3'b011;
        req.write_data = 8'h00;

        finish_item(req);

        //-------------------------------------------------
        // Write Slave Select Register
        //-------------------------------------------------

        req = spi_transaction::type_id::create("wr_ss");

        start_item(req);

        req.write      = 1;
        req.address    = 3'b100;
        req.write_data = 8'h01;

        finish_item(req);

        //-------------------------------------------------
        // Read Slave Select Register
        //-------------------------------------------------

        req = spi_transaction::type_id::create("rd_ss");

        start_item(req);

        req.write      = 0;
        req.address    = 3'b100;
        req.write_data = 8'h00;

        finish_item(req);

    endtask

endclass

`endif