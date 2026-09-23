`ifndef SPI_MULTI_BYTE_SEQ_SV
`define SPI_MULTI_BYTE_SEQ_SV

class spi_multi_byte_seq extends spi_base_sequence;

`uvm_object_utils(spi_multi_byte_seq)

function new(string name="spi_multi_byte_seq");
    super.new(name);
endfunction


virtual task body();

    spi_transaction tx;

    byte tx_bytes[4] = {
        8'h12,
        8'h34,
        8'h56,
        8'h78
    };
byte expected_rx[4] = {
    8'hA1,
    8'hB2,
    8'hC3,
    8'hD4
};
    byte rx_data;


    //-----------------------------------
    // Select slave
    //-----------------------------------
    tx = spi_transaction::type_id::create("ss_write");

    start_item(tx);

    tx.address    = 3'h4;
    tx.write      = 1;
    tx.write_data = 8'h01;

    finish_item(tx);



    //-----------------------------------
    // Enable SPI master
    //-----------------------------------
    tx = spi_transaction::type_id::create("spi_enable");

    start_item(tx);

    tx.address    = 3'h0;
    tx.write      = 1;
    tx.write_data = 8'h50;

    finish_item(tx);



    //-----------------------------------
    // Send multiple bytes
    //-----------------------------------
    foreach(tx_bytes[i])
    begin

        //-----------------------------------
        // Write TX byte
        //-----------------------------------
        tx = spi_transaction::type_id::create("tx_byte");

        start_item(tx);

        tx.address    = 3'h2;
        tx.write      = 1;
        tx.write_data = tx_bytes[i];

        finish_item(tx);



        `uvm_info("MULTI_BYTE",
            $sformatf("TX BYTE = %02h", tx_bytes[i]),
            UVM_LOW)



        //-----------------------------------
        // Wait for SPI shifting
        //-----------------------------------
        #5000;



        //-----------------------------------
        // Read RX byte
        //-----------------------------------
        tx = spi_transaction::type_id::create("rx_byte");

        start_item(tx);

        tx.address = 3'h2;
        tx.write   = 0;

        finish_item(tx);


        rx_data = tx.read_data;



        //-----------------------------------
        // Compare
        //-----------------------------------
     if(rx_data == expected_rx[i])

    `uvm_info("MULTI_BYTE",
        $sformatf("PASS TX=%02h EXPECTED_RX=%02h ACTUAL_RX=%02h",
                  tx_bytes[i],
                  expected_rx[i],
                  rx_data),
        UVM_LOW)

else

    `uvm_error("MULTI_BYTE",
        $sformatf("FAIL TX=%02h EXPECTED_RX=%02h ACTUAL_RX=%02h",
                  tx_bytes[i],
                  expected_rx[i],
                  rx_data))
    end


endtask

endclass

`endif