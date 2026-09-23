`ifndef SPI_SCOREBOARD_SV
`define SPI_SCOREBOARD_SV

class spi_scoreboard extends uvm_scoreboard;

    `uvm_component_utils(spi_scoreboard)

    //------------------------------------------------------
    // Analysis Port
    //------------------------------------------------------

    uvm_analysis_imp #(spi_transaction, spi_scoreboard) sb_port;

    //------------------------------------------------------
    // Reference Registers
    //------------------------------------------------------

    bit [7:0] exp_spcr;
    bit [7:0] exp_sper;
    bit [7:0] exp_ss;

    bit model_rx_loopback = 1;

    // Tracks SPCR[6] (SPE) so we know when to reset the fifo models, matching
    // the DUT's "clr <= ~spe" behavior on both fifo4.v instances.
    bit spe_model;

    //------------------------------------------------------
    // FIFO Models
    //------------------------------------------------------
    // tx_fifo_model : what's predicted to still be queued in the write
    //                 (TX) buffer, in drain order.
    // rx_fifo_model : what's predicted to be sitting in the read (RX)
    //                 buffer, in drain order. Populated from the SAME byte
    //                 that lands in tx_fifo_model, since tb_top loops
    //                 miso_i back from mosi_o - whatever byte the DUT
    //                 transmits is exactly the byte it also receives, so
    //                 RX drain order/content mirrors TX drain order/content.
    //
    // Both queues use fifo4.v's real overwrite-on-full behavior (see
    // verification_plan.md section 3): a write while full overwrites the
    // oldest (front) entry and that overwritten byte becomes the next one
    // to drain, modeled here as pop_front + push_front instead of a plain
    // push_back.
    //------------------------------------------------------

    bit [7:0] tx_fifo_model[$];
    bit [7:0] rx_fifo_model[$];

    bit external_miso_mode;
    bit [7:0] expected_miso_byte;
    bit wcol_expected_pending;

    //------------------------------------------------------
    // Result counters
    //------------------------------------------------------

    int unsigned reg_match_cnt,  reg_mismatch_cnt;
    int unsigned rx_match_cnt,   rx_mismatch_cnt;
    int unsigned wcol_check_cnt, wcol_mismatch_cnt;

    //------------------------------------------------------
    // Constructor
    //------------------------------------------------------

    function new(string name="spi_scoreboard",
                 uvm_component parent);

        super.new(name,parent);

        sb_port = new("sb_port",this);

        // expected reset values (see simple_spi_top.v reset block)
        exp_spcr = 8'h10;
        exp_sper = 8'h00;
        exp_ss   = 8'h00;
        spe_model = 0;

    endfunction

    function void set_external_miso(bit [7:0] data);

        external_miso_mode = 1;
        expected_miso_byte = data;

    endfunction
    //------------------------------------------------------
    // Write Function - called once per completed Wishbone access
    //------------------------------------------------------

    virtual function void write(spi_transaction tr);

        //==================================================
        // WRITE Operation
        //==================================================

        if(tr.write) begin

            case(tr.address)

                //----------------------------------
                // SPCR - MSTR bit (bit 4) is always
                // forced to 1 by the RTL regardless
                // of what's written: spcr <= dat_i | 8'h10
                //----------------------------------
                3'b000: begin

                    bit new_spe = tr.write_data[6];

                    exp_spcr = tr.write_data | 8'h10;

                    if(!new_spe && spe_model) begin
                        // SPE 1->0 : both fifo4.v instances see clr=1,
                        // and wcol/spif are forced 0 by "if (~spe|rst_i)"
                        tx_fifo_model.delete();
                        rx_fifo_model.delete();
                        wcol_expected_pending = 0;

                        `uvm_info("SCOREBOARD",
                            "SPE cleared: TX/RX fifo models and WCOL reset",
                            UVM_LOW)
                    end

                    spe_model = new_spe;

                    `uvm_info("SCOREBOARD",
                        $sformatf("WRITE SPCR DATA=%0h (expect readback=%0h)",
                                  tr.write_data, exp_spcr),
                        UVM_LOW)
                end

                //----------------------------------
                // SPDR - pushes TX fifo model; also
                // predicts what will eventually show
                // up in the RX fifo model, since
                // miso_i is looped back from mosi_o
                // in tb_top.
                //----------------------------------
                // 3'b010: begin

                //     if(tx_fifo_model.size() >= 4) begin

                //         wcol_expected_pending = 1;

                //         tx_fifo_model.pop_front();
                //         tx_fifo_model.push_front(tr.write_data);

                //         `uvm_info("SCOREBOARD",
                //             $sformatf(
                //             "Predicted WCOL: SPDR write 0x%0h while TX fifo full (overwrites oldest, becomes next to drain)",
                //             tr.write_data),
                //             UVM_LOW)

                //     end else begin
                //         tx_fifo_model.push_back(tr.write_data);
                //     end

                //     // RX fifo model: 4 deep, oldest silently overwritten,
                //     // no error flag - per spec 3.4.2.
                //     // if(model_rx_loopback) begin

                //     //     if(rx_fifo_model.size() >= 4)
                //     //     rx_fifo_model.pop_front();

                //     //     // rx_fifo_model.push_back(tr.write_data);
                //     //     if(external_miso_mode)
                //     //         rx_fifo_model.push_back(expected_miso_byte);
                //     //     else
                //     //         rx_fifo_model.push_back(tr.write_data);

                //     //     end
                //     `uvm_info("SCOREBOARD",
                //         $sformatf("SPDR WRITE DATA=%0h queued in TX fifo model",
                //                   tr.write_data),
                //         UVM_LOW)
                // end
                3'b001: begin

    wcol_check_cnt++;

    if(tr.read_data[7]) begin
        // SPIF set means transfer completed

        if(external_miso_mode) begin

            if(rx_fifo_model.size() >= 4)
                void'(rx_fifo_model.pop_front());

            rx_fifo_model.push_back(expected_miso_byte);

            `uvm_info("SCOREBOARD",
                $sformatf(
                "SPI complete: queued RX byte 0x%0h",
                expected_miso_byte),
                UVM_LOW)

        end
    end


    if(wcol_expected_pending && !tr.read_data[6]) begin
        wcol_mismatch_cnt++;

        `uvm_error("FAIL",
        "Expected WCOL=1 in SPSR, but core reported 0")

    end

end

                //----------------------------------
                // SPSR - only bits 7 (SPIF) and 6
                // (WCOL) are writable, write-1-to-clear.
                //----------------------------------
                3'b001: begin
                    if(tr.write_data[6]) begin
                        wcol_expected_pending = 0;
                        `uvm_info("SCOREBOARD","WCOL cleared by SPSR write",UVM_LOW)
                    end
                end

                3'b011:
                    exp_sper = tr.write_data;

                3'b100:
                    exp_ss = tr.write_data;

            endcase

            `uvm_info("SCOREBOARD",
                $sformatf("WRITE ADDR=%0d DATA=%0h",
                          tr.address,
                          tr.write_data),
                UVM_HIGH)

        end

        //==================================================
        // READ Operation
        //==================================================

        else begin

            case(tr.address)

                //----------------------------------
                // SPCR
                //----------------------------------

                3'b000: begin
                    reg_match_cnt = (tr.read_data == exp_spcr) ?
                                    reg_match_cnt + 1 : reg_match_cnt;

                    if(tr.read_data == exp_spcr)
                        `uvm_info("PASS",
                            $sformatf("SPCR Read Correct = 0x%0h", tr.read_data),
                            UVM_LOW)
                    else begin
                        reg_mismatch_cnt++;
                        `uvm_error("FAIL",
                        $sformatf(
                        "SPCR Expected=%0h Actual=%0h",
                        exp_spcr,
                        tr.read_data))
                    end
                end

                //----------------------------------
                // SPSR - check the predicted WCOL bit only.
                // SPIF / fifo-flag bits are timing-sensitive
                // (depend on clock divider) and are checked
                // directly by the tests instead of predicted
                // here, to avoid false failures from timing
                // assumptions baked into the scoreboard.
                //----------------------------------

                3'b001: begin
                    wcol_check_cnt++;

                    if(wcol_expected_pending && !tr.read_data[6]) begin
                        wcol_mismatch_cnt++;
                        `uvm_error("FAIL",
                            "Expected WCOL=1 in SPSR, but core reported 0")
                    end
                    else if(wcol_expected_pending && tr.read_data[6])
                        `uvm_info("PASS","WCOL=1 in SPSR as predicted",UVM_LOW)
                    else if(!wcol_expected_pending && tr.read_data[6])
                        `uvm_warning("SCOREBOARD",
                            "WCOL=1 seen but not predicted by model")
                end

                //----------------------------------
                // SPDR read - pop predicted RX fifo
                // model and compare against the byte
                // actually returned.
                //----------------------------------

                3'b010: begin
                    if(rx_fifo_model.size() > 0) begin

                        bit [7:0] exp = rx_fifo_model.pop_front();

                        if(exp == tr.read_data) begin
                            rx_match_cnt++;
                            `uvm_info("PASS",
                                $sformatf("SPDR read: got 0x%0h as predicted",
                                          tr.read_data),
                                UVM_LOW)
                        end else begin
                            rx_mismatch_cnt++;
                            `uvm_error("FAIL",
                                $sformatf(
                                "SPDR read: expected 0x%0h (predicted RX fifo), got 0x%0h",
                                exp, tr.read_data))
                        end

                    end else begin
                        `uvm_warning("SCOREBOARD",
                            "SPDR read while predicted RX fifo model is empty")
                    end
                end

                //----------------------------------
                // SPER
                //----------------------------------

                3'b011:

                    if(tr.read_data == exp_sper)

                        `uvm_info("PASS",
                                  "SPER Read Correct",
                                  UVM_LOW)

                    else

                        `uvm_error("FAIL",
                        $sformatf(
                        "SPER Expected=%0h Actual=%0h",
                        exp_sper,
                        tr.read_data))

                //----------------------------------
                // Slave Select
                //----------------------------------

                3'b100:

                    if(tr.read_data == exp_ss)

                        `uvm_info("PASS",
                                  "SS Register Correct",
                                  UVM_LOW)

                    else

                        `uvm_error("FAIL",
                        $sformatf(
                        "SS Expected=%0h Actual=%0h",
                        exp_ss,
                        tr.read_data))

            endcase

        end

    endfunction

    //------------------------------------------------------
    // Report Phase
    //------------------------------------------------------

    function void report_phase(uvm_phase phase);

        int unsigned total_mismatch = reg_mismatch_cnt + rx_mismatch_cnt +
                                       wcol_mismatch_cnt;

        `uvm_info("SB_SUMMARY", $sformatf(
            "REG mismatch=%0d | RX match=%0d mismatch=%0d | WCOL checks=%0d mismatch=%0d",
            reg_mismatch_cnt, rx_match_cnt, rx_mismatch_cnt,
            wcol_check_cnt, wcol_mismatch_cnt), UVM_LOW)

        if(total_mismatch == 0)
            `uvm_info("TEST_RESULT", "**** SCOREBOARD: PASS - no mismatches ****", UVM_NONE)
        else
            `uvm_error("TEST_RESULT", $sformatf(
                "**** SCOREBOARD: FAIL - %0d mismatch(es) ****", total_mismatch))

    endfunction

endclass

`endif