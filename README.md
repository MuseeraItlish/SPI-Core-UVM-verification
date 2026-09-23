# SPI-Core-UVM-verification
## Overview

This project presents the functional verification of an SPI (Serial Peripheral Interface) Core using UVM (Universal Verification Methodology).The verification environment verifies the SPI Core at both the Wishbone bus/register level and the SPI pin level.
A dedicated SPI Pin UVC is also developed to monitor MOSI and provide MISO responses to the DUT, allowing SPI pin-level behavior to be verified separately from the Wishbone interface.

## Verification Environment

The verification environment is developed using UVM.

The main components include:

Transaction
Sequencer
Driver
Monitor
Scoreboard
Test Sequences
SPI Pin UVC (slave)

## SPI Pin UVC

A separate SPI Pin UVC is used for pin-level verification.

It contains:

SPI Pin Transaction
SPI Pin Driver
SPI Pin Monitor
SPI Pin Scoreboard

The SPI Pin Monitor observes the SPI clock and samples MOSI data from the DUT.

The SPI Pin Driver provides MISO data to the DUT and models the behavior of an external SPI slave.

## Tools and Technologies

-Cadence Xcelium
-UVM

