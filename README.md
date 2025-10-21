# Verilog UART Transmitter & Testbench

This project is a simple implementation of a UART (Universal Asynchronous Receiver-Transmitter) protocol in Verilog. It consists of two main modules:

1.  **`UART_Transmiter.v`**: The core hardware logic module. This is a Finite State Machine (FSM) that serializes and transmits a hardcoded string over a single output pin.
2.  **`UART_Transmiter_tb.v`**: A Verilog **testbench** used to simulate and verify the `UART_Transmiter`. It generates the clock, handles reset, and "listens" to the `uart_tx` line to print the received message to the simulation console.

## Features

### `UART_Transmiter.v` (The Hardware)
* **FSM-Based Design**: Implemented as a 4-state Finite State Machine:
    * `TX_STATE_IDLE`
    * `TX_STATE_START_BIT`
    * `TX_STATE_WRITE`
    * `TX_STATE_STOP_BIT`
* **Hardcoded Message**: The transmitter contains an internal memory that is initialized to send the 14-character string `"Victor Padial "`.
* **Standard UART Frame**: Transmits data in the standard 8N1 format (1 Start Bit, 8 Data Bits, 1 Stop Bit).
* **Configurable Baud Rate**: The baud rate is set by the `DELAY_FRAMES` parameter. The default value is configured to achieve 115200 bps when used with a 27 MHz clock.

### `UART_Transmiter_tb.v` (The Testbench)
* **Device Under Test (DUT)**: Instantiates the `UART_Transmiter` module for testing.
* **Clock Generation**: Generates a 27 MHz (37 ns period) clock signal for the simulation.
* **Reset Handling**: Applies an initial reset signal to the DUT to ensure it starts in a known state.
* **Serial Data "Receiver"**:
    * Waits for the start bit (a low signal) on the `uart_tx` line.
    * Samples the line in the middle of each bit period for accuracy.
    * Loops 8 times to read each data bit, storing them in a register.
    * Verifies that the stop bit is high, printing an error if it's not.
* **Verification**: Uses the Verilog system task `$display` to print the received character (`%c`) to the simulation console, allowing the user to visually verify that the transmitted message is correct.
* **Simulation Control**: The simulation is set to run for a fixed duration and then automatically stop using `$finish`.

## How to Use

This project is intended to be run in a Verilog simulator (like ModelSim, Vivado Simulator, VCS, or an online tool like EDAPlayground).

1.  Add both `UART_Transmiter.v` and `UART_Transmiter_tb.v` to your simulation project.
2.  Set the testbench module (`UART_Transmiter_tb`) as the top-level module for the simulation.
3.  Compile and run the simulation.
4.  Observe the simulator's console. You should see the message "Victor Padial " printed out, character by character, as the testbench receives and decodes the serial data.
