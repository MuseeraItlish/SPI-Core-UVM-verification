`ifndef SPI_PIN_RESPONSE_SEQ_SV
`define SPI_PIN_RESPONSE_SEQ_SV

class spi_pin_response_seq extends uvm_sequence #(spi_pin_transaction);

    `uvm_object_utils(spi_pin_response_seq)

    function new(string name="spi_pin_response_seq");
        super.new(name);
    endfunction

    virtual task body();

        spi_pin_transaction req;

        bit [7:0] resp[4] = '{8'hA1,8'hB2,8'hC3,8'hD4};

        foreach(resp[i]) begin

            req = spi_pin_transaction::type_id::create($sformatf("req%0d",i));

            start_item(req);
            req.miso_data = resp[i];
            finish_item(req);

            `uvm_info("PIN_SEQ",
                $sformatf("Queued MISO byte %0h",resp[i]),
                UVM_LOW)

        end

    endtask

endclass

`endif