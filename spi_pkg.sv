package spi_pkg;

    import uvm_pkg::*;
    `include "uvm_macros.svh"



    //=========================================
    // Transaction
    //=========================================
    `include "env/spi_transaction.sv"

    //=========================================
    // Sequencer
    //=========================================
    `include "env/spi_sequencer.sv"

    //=========================================
    // Driver
    //=========================================
    `include "env/spi_driver.sv"

    //=========================================
    // Monitor
    //=========================================
    `include "env/spi_monitor.sv"

//=========================================
    // SPI Pin-Level UVC (MOSI / MISO)
    // Separate from spi_agent above: this one drives/monitors
    // the serial pins (sck_o, ss_o, mosi_o, miso_i) instead of
    // the Wishbone bus.
    //=========================================
    `include "env/spi_pin_transaction.sv"
    `include "env/spi_pin_sequencer.sv"
    `include "env/spi_pin_driver.sv"
    `include "env/spi_pin_monitor.sv"
    `include "env/spi_pin_scoreboard.sv"
    `include "env/spi_pin_agent.sv"
    `include "env/spi_pin_response_seq.sv"
    //=========================================
    // Scoreboard
    //=========================================
    `include "env/spi_scoreboard.sv"

    //=========================================
    // Coverage
    //=========================================
    `include "env/spi_coverage.sv"

    //=========================================
    // Agent
    //=========================================
    `include "env/spi_agent.sv"

    //=========================================
    // Environment
    //=========================================
    `include "env/spi_env.sv"

    //=========================================
    // Sequences
    //=========================================
    `include "seq/spi_base_seq.sv"
    `include "seq/spi_reset_sequence.sv"
    `include "seq/spi_register_sequence.sv"
    `include "seq/spi_rand_seq.sv"
    `include "seq/spi_fifo_fill_seq.sv"
    `include "seq/spi_enable_disable_seq.sv"
    `include "seq/spi_multi_byte_seq.sv"

    `include "seq/spi_fullduplex_seq.sv"
    `include "seq/spi_loopback_seq.sv"

    //=========================================
    // Tests
    //=========================================
    `include "tests/base_test.sv"
    `include "tests/spi_reset_test.sv"
    `include "tests/reg_write_test.sv"
    `include "tests/random_test.sv"
    `include "tests/spi_fifo_fill_test.sv"
    `include "tests/spi_enable_disable_test.sv"
    `include "tests/spi_multi_byte_test.sv"
    `include "tests/spi_full_duplex_test.sv"
    `include "tests/spi_loopback_test.sv"

endpackage