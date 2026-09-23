`ifndef SPI_FIFO_FILL_SEQUENCE_SV
`define SPI_FIFO_FILL_SEQUENCE_SV

class spi_fifo_fill_sequence extends spi_base_sequence;

    `uvm_object_utils(spi_fifo_fill_sequence)

    function new(string name="spi_fifo_fill_sequence");
        super.new(name);
    endfunction

    virtual task body();

       

       bit [7:0] data_array[4];

        super.body();

       data_array[0]=8'h11;
       data_array[1]=8'h22;
       data_array[2]=8'h33;
       data_array[3]=8'h44;


        foreach(data_array[i]) begin

            req = spi_transaction::type_id::create($sformatf("req_%0d",i));

            start_item(req);

            req.write      = 1;
            req.address    = 3'b010;      // FIFO Register
            req.write_data = data_array[i];

            finish_item(req);

        end

        // Read SPSR to check FULL bit
        req = spi_transaction::type_id::create("status_read");

        start_item(req);

        req.write   = 0;
        req.address = 3'b001;             // SPSR

        finish_item(req);

    endtask

endclass

`endif