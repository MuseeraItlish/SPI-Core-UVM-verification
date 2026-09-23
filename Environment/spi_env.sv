`ifndef SPI_ENV_SV
`define SPI_ENV_SV

class spi_env extends uvm_env;

    `uvm_component_utils(spi_env)

    //---------------------------------------------
    // Components
    //---------------------------------------------

    spi_agent      agent;
    spi_scoreboard scoreboard;
    spi_coverage   coverage;

    // Separate SPI Pin-Level UVC (MOSI/MISO) - independent of the
    // Wishbone-side spi_agent above. See env/spi_pin_agent.sv.
    spi_pin_agent      pin_agent;
    spi_pin_scoreboard pin_scoreboard;

    //---------------------------------------------
    // Constructor
    //---------------------------------------------

    function new(string name="spi_env",
                 uvm_component parent);

        super.new(name,parent);

    endfunction

    //---------------------------------------------
    // Build Phase
    //---------------------------------------------

    function void build_phase(uvm_phase phase);

        super.build_phase(phase);

        agent = spi_agent::type_id::create("agent",this);

        scoreboard = spi_scoreboard::type_id::create(
                        "scoreboard",
                        this);

        coverage = spi_coverage::type_id::create(
                        "coverage",
                        this);

        pin_agent = spi_pin_agent::type_id::create(
                        "pin_agent",
                        this);

        pin_scoreboard = spi_pin_scoreboard::type_id::create(
                        "pin_scoreboard",
                        this);

    endfunction

    //---------------------------------------------
    // Connect Phase
    //---------------------------------------------

    function void connect_phase(uvm_phase phase);

        super.connect_phase(phase);

        agent.monitor.mon_ap.connect(
            scoreboard.sb_port
        );

        agent.monitor.mon_ap.connect(
            coverage.analysis_export
        );

        // Feed both UVCs into the pin scoreboard so it can cross-check
        // Wishbone-side SPDR writes/reads against what actually happened
        // on the serial pins.
        agent.monitor.mon_ap.connect(
            pin_scoreboard.wb_export
        );

        pin_agent.monitor.mon_ap.connect(
            pin_scoreboard.pinmon_export
        );

        pin_agent.driver.drv_ap.connect(
            pin_scoreboard.pindrv_export
        );

    endfunction

endclass

`endif