class spi_enable_disable_seq extends spi_base_sequence;

`uvm_object_utils(spi_enable_disable_seq)

function new(string name="spi_enable_disable_seq");
super.new(name);
endfunction


virtual task body();

spi_transaction tr;


// Disable SPI

tr = spi_transaction::type_id::create("disable_spi");

start_item(tr);

tr.address = 3'b000;      // SPCR
tr.write = 1;
tr.write_data = 8'h00;

finish_item(tr);



#50;


// Try sending data when disabled

tr = spi_transaction::type_id::create("data_disabled");

start_item(tr);

tr.address = 3'b010;       // SPDR
tr.write = 1;
tr.write_data = 8'hAA;

finish_item(tr);



#50;


// Enable SPI

tr = spi_transaction::type_id::create("enable_spi");

start_item(tr);

tr.address = 3'b000;
tr.write = 1;
tr.write_data = 8'h10;

finish_item(tr);



#50;


// Send data after enable

tr = spi_transaction::type_id::create("data_enabled");

start_item(tr);

tr.address = 3'b010;
tr.write = 1;
tr.write_data = 8'h55;

finish_item(tr);



endtask

endclass