`ifndef SPI_PIN_TRANSACTION_SV
`define SPI_PIN_TRANSACTION_SV

//==========================================================
// spi_pin_transaction
//
// Item for the SPI Pin-Level UVC (spi_pin_agent). This UVC
// is deliberately separate from spi_agent/spi_transaction,
// which only ever talks Wishbone. This one talks the actual
// serial pins: sck_o, ss_o, mosi_o, miso_i.
//
//   miso_data - byte to force onto miso_i for the DUT's next
//               transfer. Set by a sequence and consumed by
//               spi_pin_driver. Also re-used (by the driver
//               itself) to report, after the fact, exactly
//               what it drove.
//   mosi_data - byte spi_pin_monitor reconstructed by
//               sampling mosi_o directly off the pin. Only
//               ever filled in by the monitor, never by a
//               sequence.
//
// Both directions share one item type, same convention as
// spi_transaction (write_data / read_data) in the Wishbone
// UVC.
//==========================================================

class spi_pin_transaction extends uvm_sequence_item;

    `uvm_object_utils(spi_pin_transaction)

    rand bit [7:0] miso_data;
    bit      [7:0] mosi_data;
        bit is_miso_drive;

    function new(string name = "spi_pin_transaction");
        super.new(name);
    endfunction

    function string convert2string();
        return $sformatf("MISO_DATA=0x%0h MOSI_DATA=0x%0h", miso_data, mosi_data);
    endfunction

endclass

`endif
