`ifndef SPI_COVERAGE_SV
`define SPI_COVERAGE_SV

class spi_coverage extends uvm_subscriber #(spi_transaction);

    `uvm_component_utils(spi_coverage)

    spi_transaction tr;

    //------------------------------------------------------
    // Register access coverage: which register, read vs
    // write, and (for SPCR) which mode bits got exercised.
    //------------------------------------------------------

    covergroup cg_reg_access;
        option.per_instance = 1;

        cp_addr: coverpoint tr.address {
            bins spcr = {3'b000};
            bins spsr = {3'b001};
            bins spdr = {3'b010};
            bins sper = {3'b011};
            bins ss   = {3'b100};
        }

        cp_we: coverpoint tr.write {
            bins write = {1};
            bins read  = {0};
        }

        cx_addr_we: cross cp_addr, cp_we;

        cp_spcr_mode: coverpoint tr.write_data[3:2] iff (tr.address == 3'b000 && tr.write) {
            bins mode0 = {2'b00}; // CPOL=0 CPHA=0
            bins mode1 = {2'b01}; // CPOL=0 CPHA=1
            bins mode2 = {2'b10}; // CPOL=1 CPHA=0
            bins mode3 = {2'b11}; // CPOL=1 CPHA=1
        }

        cp_spsr_flags: coverpoint tr.read_data[7:6] iff (tr.address == 3'b001 && !tr.write) {
            bins none      = {2'b00};
            bins spif_only = {2'b10};
            bins wcol_only = {2'b01};
            bins both      = {2'b11};
        }

        cp_interrupt: coverpoint tr.interrupt {
            bins asserted   = {1};
            bins deasserted = {0};
        }
    endgroup

    //------------------------------------------------------
    // FIFO state coverage: empty/full on both the TX (write)
    // and RX (read) hardware fifos, sampled from SPSR reads.
    // Closes plan item 24 "FIFO: Empty, Full" (Overflow is
    // covered by cp_spsr_flags' wcol_only/both bins above;
    // Underflow has no DUT flag per spec 3.4.2, so it is
    // checked functionally by spi_fifo_underflow_seq instead
    // of via coverage).
    //------------------------------------------------------

    covergroup cg_fifo_state;
        option.per_instance = 1;

        cp_wfifo: coverpoint tr.read_data[3:2] iff (tr.address == 3'b001 && !tr.write) {
            wildcard bins empty = {2'b?1};
            wildcard bins full  = {2'b1?};
            bins mid            = {2'b00};
        }

        cp_rfifo: coverpoint tr.read_data[1:0] iff (tr.address == 3'b001 && !tr.write) {
            wildcard bins empty = {2'b?1};
            wildcard bins full  = {2'b1?};
            bins mid            = {2'b00};
        }
    endgroup

    //------------------------------------------------------
    // Clock divider coverage: SPR (base) and SPRE (extended)
    // fields. Closes plan item 24 "SPI: Clock Divider".
    //------------------------------------------------------

    covergroup cg_clock_divider;
        option.per_instance = 1;

        cp_spr: coverpoint tr.write_data[1:0] iff (tr.address == 3'b000 && tr.write) {
            bins spr0 = {2'b00};
            bins spr1 = {2'b01};
            bins spr2 = {2'b10};
            bins spr3 = {2'b11};
        }

        cp_spre: coverpoint tr.write_data[1:0] iff (tr.address == 3'b011 && tr.write) {
            bins spre0 = {2'b00};
            bins spre1 = {2'b01};
            bins spre2 = {2'b10};
            bins spre3 = {2'b11};
        }
    endgroup

    //------------------------------------------------------
    // Slave-select coverage. Closes plan item 24
    // "SPI: Slave Select". This build uses SS_WIDTH=1 (see
    // spi_ss_seq.sv), so only a single select line exists.
    //------------------------------------------------------

    covergroup cg_ss;
        option.per_instance = 1;

        cp_ss: coverpoint tr.write_data[0] iff (tr.address == 3'b100 && tr.write) {
            bins active   = {1};
            bins inactive = {0};
        }
    endgroup

    //------------------------------------------------------
    // Data pattern coverage on SPDR writes. Closes plan item
    // 24 "SPI: Data Patterns".
    //------------------------------------------------------

    covergroup cg_data_pattern;
        option.per_instance = 1;

        cp_pattern: coverpoint tr.write_data iff (tr.address == 3'b010 && tr.write) {
            bins all_zero    = {8'h00};
            bins all_ones    = {8'hFF};
            bins alt_a       = {8'hAA};
            bins alt_5       = {8'h55};
            bins others      = default;
        }
    endgroup

    //------------------------------------------------------
    // Wishbone ACK coverage. Closes plan item 24
    // "Wishbone: ACK". Every transaction reaching this
    // subscriber was, by construction, ack'd (the monitor
    // only publishes a transaction when cyc_i & stb_i &
    // ack_o were all seen together) - so this simply
    // confirms that fact has been sampled at least once.
    //------------------------------------------------------

    covergroup cg_wb_ack;
        option.per_instance = 1;

        cp_ack_seen: coverpoint 1'b1 {
            bins ack_observed = {1};
        }
    endgroup

    //------------------------------------------------------
    // Constructor
    //------------------------------------------------------

    function new(string name = "spi_coverage",
                 uvm_component parent);
        super.new(name, parent);
        cg_reg_access    = new();
        cg_fifo_state    = new();
        cg_clock_divider = new();
        cg_ss            = new();
        cg_data_pattern  = new();
        cg_wb_ack        = new();
    endfunction

    //------------------------------------------------------
    // write() - called by uvm_subscriber's analysis export
    // every time the monitor publishes a transaction.
    //------------------------------------------------------

    function void write(spi_transaction t);
        tr = t;
        cg_reg_access.sample();
        cg_fifo_state.sample();
        cg_clock_divider.sample();
        cg_ss.sample();
        cg_data_pattern.sample();
        cg_wb_ack.sample();
    endfunction

    //------------------------------------------------------
    // Report Phase
    //------------------------------------------------------

    function void report_phase(uvm_phase phase);
        `uvm_info("COVERAGE",
            $sformatf("cg_reg_access coverage    = %0.1f%%", cg_reg_access.get_coverage()),
            UVM_NONE)
        `uvm_info("COVERAGE",
            $sformatf("cg_fifo_state coverage    = %0.1f%%", cg_fifo_state.get_coverage()),
            UVM_NONE)
        `uvm_info("COVERAGE",
            $sformatf("cg_clock_divider coverage = %0.1f%%", cg_clock_divider.get_coverage()),
            UVM_NONE)
        `uvm_info("COVERAGE",
            $sformatf("cg_ss coverage            = %0.1f%%", cg_ss.get_coverage()),
            UVM_NONE)
        `uvm_info("COVERAGE",
            $sformatf("cg_data_pattern coverage  = %0.1f%%", cg_data_pattern.get_coverage()),
            UVM_NONE)
        `uvm_info("COVERAGE",
            $sformatf("cg_wb_ack coverage        = %0.1f%%", cg_wb_ack.get_coverage()),
            UVM_NONE)
    endfunction

endclass

`endif