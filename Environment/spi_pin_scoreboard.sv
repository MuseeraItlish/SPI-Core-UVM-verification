`ifndef SPI_PIN_SCOREBOARD_SV
`define SPI_PIN_SCOREBOARD_SV

`uvm_analysis_imp_decl(_wb)
`uvm_analysis_imp_decl(_pinmon)
`uvm_analysis_imp_decl(_pindrv)

//==========================================================
// spi_pin_scoreboard
//
// Cross-checks the existing Wishbone UVC (spi_agent/spi_monitor)
// against the new pin-level UVC (spi_pin_agent):
//
//   MOSI check: every SPDR write seen on the Wishbone side is
//   queued as "expected on the wire next"; every byte
//   spi_pin_monitor captures directly off mosi_o is popped
//   against it and compared bit-for-bit.
//
//   MISO check: every byte spi_pin_driver is explicitly asked
//   to force onto miso_i is queued; every SPDR *read* on the
//   Wishbone side is popped against it and compared. If they
//   don't match - or worse, if the RX FIFO returned the MOSI
//   byte instead - that's flagged as a real bug, not just "some
//   read happened".
//
// checks_enabled defaults OFF so this scoreboard is inert for
// every pre-existing test (which never call enable_checks()) -
// it only starts comparing once a test that actually wants
// pin-level checking turns it on. The agent/monitor/driver
// still run for every test either way; only the *checking* is
// opt-in.
//==========================================================

class spi_pin_scoreboard extends uvm_scoreboard;

    `uvm_component_utils(spi_pin_scoreboard)

    uvm_analysis_imp_wb     #(spi_transaction,     spi_pin_scoreboard) wb_export;
    uvm_analysis_imp_pinmon #(spi_pin_transaction, spi_pin_scoreboard) pinmon_export;
    uvm_analysis_imp_pindrv #(spi_pin_transaction, spi_pin_scoreboard) pindrv_export;

    bit checks_enabled;

   bit [7:0] exp_mosi_q[$];   // Expected MOSI from SPDR writes
bit [7:0] exp_miso_q[$];   // Expected MISO driven by pin driver

int unsigned mosi_match_cnt;
int unsigned mosi_mismatch_cnt;

int unsigned miso_match_cnt;
int unsigned miso_mismatch_cnt;

    function new(string name = "spi_pin_scoreboard",
                 uvm_component parent);

        super.new(name, parent);

        wb_export     = new("wb_export", this);
        pinmon_export = new("pinmon_export", this);
        pindrv_export = new("pindrv_export", this);

    endfunction

    // Call from a test's run_phase before starting stimulus to opt in
    // to pin-level checking. Clears any stale queue contents first.
    function void enable_checks();
        checks_enabled = 1;
        exp_mosi_q.delete();
        exp_miso_q.delete();
    endfunction

    //------------------------------------------------------
    // Wishbone side: SPDR writes feed the MOSI expectation,
    // SPDR reads get checked against the MISO expectation.
    //------------------------------------------------------

    virtual function void write_wb(spi_transaction tr);

        if(!checks_enabled)
            return;

        if(tr.write && tr.address == 3'b010) begin

            exp_mosi_q.push_back(tr.write_data);

        end else if(!tr.write && tr.address == 3'b010) begin

            if(exp_miso_q.size() > 0) begin

                bit [7:0] exp = exp_miso_q.pop_front();

                if(exp == tr.read_data) begin
                    miso_match_cnt++;
                    `uvm_info("PIN_SB",
                        $sformatf("PASS: MISO byte 0x%0h correctly captured into RX FIFO", exp),
                        UVM_LOW)
                end else begin
                    miso_mismatch_cnt++;
                    `uvm_error("PIN_SB",
                        $sformatf("MISO mismatch: forced 0x%0h onto miso_i, RX FIFO read back 0x%0h",
                                  exp, tr.read_data))
                end

            end
            // else: this SPDR read wasn't preceded by an explicit pin-
            // driver request (e.g. plain default-loopback traffic) -
            // nothing queued to check it against, skip silently.

        end

    endfunction

    //------------------------------------------------------
    // Pin monitor side: one entry per byte reconstructed off
    // mosi_o.
    //------------------------------------------------------

    virtual function void write_pinmon(spi_pin_transaction tr);

    bit [7:0] exp;


    if(!checks_enabled)
        return;


    //--------------------------------------------------
    // MOSI check
    //--------------------------------------------------

    if(exp_mosi_q.size() > 0) begin

        exp = exp_mosi_q.pop_front();

        if(exp == tr.mosi_data) begin

            mosi_match_cnt++;

            `uvm_info("PIN_SB",
                $sformatf(
                "PASS MOSI: expected=0x%0h captured=0x%0h",
                exp,
                tr.mosi_data),
                UVM_LOW)

        end
        else begin

            mosi_mismatch_cnt++;

            `uvm_error("PIN_SB",
                $sformatf(
                "FAIL MOSI: expected=0x%0h captured=0x%0h",
                exp,
                tr.mosi_data))

        end

    end



    //--------------------------------------------------
    // MISO pin check
    //--------------------------------------------------

    if(exp_miso_q.size() > 0) begin

        exp = exp_miso_q.pop_front();


        if(exp == tr.miso_data) begin

            miso_match_cnt++;

            `uvm_info("PIN_SB",
                $sformatf(
                "PASS MISO PIN: driven=0x%0h captured=0x%0h",
                exp,
                tr.miso_data),
                UVM_LOW)

        end
        else begin

            miso_mismatch_cnt++;

            `uvm_error("PIN_SB",
                $sformatf(
                "FAIL MISO PIN: driven=0x%0h captured=0x%0h",
                exp,
                tr.miso_data))

        end

    end


endfunction

    //------------------------------------------------------
    // Pin driver side: one entry per byte explicitly forced
    // onto miso_i.
    //------------------------------------------------------

    virtual function void write_pindrv(spi_pin_transaction tr);

        if(!checks_enabled)
            return;

        exp_miso_q.push_back(tr.miso_data);

    endfunction

    function void report_phase(uvm_phase phase);

        int unsigned total_mismatch =
        mosi_mismatch_cnt +
        miso_mismatch_cnt;

        `uvm_info("PIN_SB_SUMMARY",
            $sformatf("MOSI match=%0d mismatch=%0d | MISO match=%0d mismatch=%0d",
                      mosi_match_cnt, mosi_mismatch_cnt, miso_match_cnt, miso_mismatch_cnt),
            UVM_LOW)

        if(!checks_enabled)
            return; // this test never opted in - nothing to report

        if(total_mismatch == 0)
            `uvm_info("TEST_RESULT", "**** PIN SCOREBOARD: PASS - no mismatches ****", UVM_NONE)
        else
            `uvm_error("TEST_RESULT",
                $sformatf("**** PIN SCOREBOARD: FAIL - %0d mismatch(es) ****", total_mismatch))

    endfunction

endclass

`endif
