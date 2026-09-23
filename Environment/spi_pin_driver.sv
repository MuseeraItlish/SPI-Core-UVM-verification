`ifndef SPI_PIN_DRIVER_SV
`define SPI_PIN_DRIVER_SV

//==========================================================
// spi_pin_driver
//
// Owns miso_i outright - tb_top no longer wires it up with a
// continuous assign. Two modes, arbitrated by
// default_loopback_enable:
//
//   1. Default (no pending item): behaves exactly like the
//      old tb_top wiring, looping miso_i from mosi_o with the
//      same #2 delay, so every test that doesn't care about
//      MISO independently still gets working RX data.
//
//   2. On request (spi_pin_transaction consumed from the
//      sequencer): drives miso_data onto miso_i one bit per
//      sck_o period, MSB first, timed to the DUT's actual
//      sample edge - then reports what it drove on drv_ap and
//      falls back to loopback mode.
//
// Timing basis (traced from simple_spi_top.v, not guessed):
// for CPOL=0/CPHA=0, miso_i is shifted into treg on the same
// clk_i edge that also drives sck_o from high back to low
// (falling edge), so each bit must be valid from just after a
// rising edge through the following falling edge.
//==========================================================

class spi_pin_driver extends uvm_driver #(spi_pin_transaction);

    `uvm_component_utils(spi_pin_driver)

    virtual spi_if vif;

    // Publishes one item per byte actually forced onto miso_i (mode 2
    // above only - never fires for the passive default-loopback mode).
    uvm_analysis_port #(spi_pin_transaction) drv_ap;

    bit          default_loopback_enable;
    int unsigned transfers_driven;

    function new(string name = "spi_pin_driver",
                 uvm_component parent);
        super.new(name, parent);
        drv_ap = new("drv_ap", this);
    endfunction

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);

        if(!uvm_config_db #(virtual spi_if)::get(this, "", "vif", vif))
            `uvm_fatal("NOVIF", "Virtual Interface not found")
    endfunction

    task run_phase(uvm_phase phase);

        spi_pin_transaction tr;

        default_loopback_enable = 1;
        vif.miso_i               = 1'b0; // matches DUT's power-on treg/mosi_o = 0

        fork
            default_loopback();
        join_none

        forever begin

            seq_item_port.get_next_item(req);

            drive_byte(req.miso_data);

            tr = spi_pin_transaction::type_id::create("tr");
            tr.miso_data = req.miso_data;
            drv_ap.write(tr);
            transfers_driven++;

            seq_item_port.item_done();

        end

    endtask

    // Mirrors the old tb_top "assign #2 miso_i = mosi_o;" wiring,
    // active any time no explicit drive request is in flight.
    task automatic default_loopback();

        forever begin
            @(vif.mosi_o);
            if(default_loopback_enable)
                vif.miso_i <= #2 vif.mosi_o;
        end

    endtask

    // Forces one byte onto miso_i, MSB first, one bit held per sck_o
    // period, synchronized to the DUT's actual sample edge.


    // task automatic drive_byte(bit [7:0] data);

    //     default_loopback_enable = 0;

    //     for(int i = 7; i >= 0; i--) begin
    //         @(negedge vif.sck_o);
    //         vif.miso_i <= data[i];
    //         @(posedge vif.sck_o);
    //     end

    //     // Hand control straight back to loopback mode, resynced to
    //     // whatever mosi_o is doing right now.
    //     default_loopback_enable = 1;
    //     vif.miso_i             <= #2 vif.mosi_o;

    // endtask

    task automatic drive_byte(bit [7:0] data);

    default_loopback_enable = 0;

    `uvm_info("PIN_DRIVER",
        $sformatf("START DRIVING MISO 0x%0h",data),
        UVM_LOW)

    for(int i=7;i>=0;i--) begin

        @(negedge vif.sck_o);

        vif.miso_i <= data[i];

        `uvm_info("PIN_DRIVER",
            $sformatf("MISO bit %0d = %0b",i,data[i]),
            UVM_LOW)

        @(posedge vif.sck_o);

    end

    default_loopback_enable=1;

endtask

    function void report_phase(uvm_phase phase);
        `uvm_info(get_type_name(),
                  $sformatf("Pin driver forced %0d explicit MISO byte(s)", transfers_driven),
                  UVM_NONE)
    endfunction

endclass

`endif
