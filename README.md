# UART Loopback System using Verilog

## Project Overview

This project implements a complete **UART (Universal Asynchronous Receiver Transmitter)** communication system in Verilog HDL using a combination of:

* Finite State Machines (FSM)
* Sequential Logic
* Shift Registers
* Baud Rate Timing Logic

The project consists of:

* UART Transmitter (TX)
* UART Receiver (RX)
* UART Loopback Module
* Simulation Testbench

The transmitter serializes parallel data into UART frames while the receiver reconstructs the serial stream back into parallel data.

The system is verified using a **UART Loopback Architecture** where the transmitter output is directly connected to the receiver input.

---

# UART Communication Basics

UART is an **asynchronous serial communication protocol** widely used in:

* Embedded Systems
* Microcontrollers
* FPGA Designs
* Computer Peripherals
* Serial Communication Interfaces

Unlike SPI or I2C, UART does not use a shared clock line.

Communication occurs using:

```text
TX Line
RX Line
Common Baud Rate
```

---

# UART Frame Format

The UART frame used in this project contains:

| Field     | Size   |
| --------- | ------ |
| Start Bit | 1 bit  |
| Data Bits | 8 bits |
| Stop Bit  | 1 bit  |

UART line remains HIGH during idle state.

Transmission format:

```text
| START | DATA[7:0] | STOP |
```

Example transmission for:

```text
10110010
```

Generated UART frame:

```text
0 0 1 0 0 1 1 0 1 1
```

Where:

* First `0` = Start Bit
* Last `1` = Stop Bit
* Data transmitted LSB first

---

# Project Architecture

```text
                +----------------+
 tx_data -----> |   UART TX      |
                |                |
                +----------------+
                         |
                         | serial_line
                         v
                +----------------+
                |   UART RX      |
                |                |
                +----------------+
                         |
                         v
                     rx_data
```

The UART TX output is directly connected to the UART RX input using an internal serial communication wire.

This creates a complete UART loopback system for end-to-end verification.

---

# Features

* UART serial data transmission
* UART serial data reception
* Configurable baud rate
* FSM-based control logic
* Start bit detection
* Stop bit validation
* Shift-register serialization
* Serial-to-parallel conversion
* Busy signal generation
* Loopback verification

---

# Inputs and Outputs

## UART TX Inputs

| Signal | Width | Description         |
| ------ | ----- | ------------------- |
| clk    | 1     | System clock        |
| rst    | 1     | Asynchronous reset  |
| load   | 1     | Start transmission  |
| data   | 8     | Parallel input data |

---

## UART TX Outputs

| Signal | Width | Description                |
| ------ | ----- | -------------------------- |
| tx     | 1     | Serial UART output         |
| busy   | 1     | Transmission active signal |

---

## UART RX Inputs

| Signal | Width | Description               |
| ------ | ----- | ------------------------- |
| clk    | 1     | System clock              |
| rst    | 1     | Asynchronous reset        |
| rx     | 1     | Incoming serial UART data |

---

## UART RX Outputs

| Signal | Width | Description                 |
| ------ | ----- | --------------------------- |
| data   | 8     | Reconstructed parallel data |

---

# UART Transmitter Design

The UART transmitter converts parallel data into serial UART frames.

---

## TX FSM States

| State   | Description              |
| ------- | ------------------------ |
| IDLE    | Waiting for transmission |
| START   | Sending start bit        |
| DATA_TX | Sending serial data bits |
| STOP    | Sending stop bit         |

---

## TX Working Principle

### 1. Data Loading

Parallel input data is loaded into a shift register:

```verilog
shift_reg <= {1'b1, data, 1'b0};
```

This creates:

```text
STOP + DATA + START
```

UART frame.

---

### 2. Start Bit Transmission

The transmitter first sends:

```text
0
```

indicating start of UART communication.

---

### 3. Data Transmission

Data bits are transmitted serially using:

```verilog
tx <= shift_reg[0];
shift_reg <= shift_reg >> 1;
```

The shift register shifts every baud interval.

---

### 4. Stop Bit Transmission

After transmitting all data bits:

```text
1
```

is transmitted as stop bit.

---

### 5. Busy Signal

The transmitter raises:

```text
busy = 1
```

during active transmission.

---

# UART Receiver Design

The UART receiver reconstructs serial data back into parallel format.

---

## RX FSM States

| State   | Description           |
| ------- | --------------------- |
| IDLE    | Waiting for start bit |
| START   | Validating start bit  |
| DATA_RX | Receiving serial data |
| STOP    | Validating stop bit   |

---

# RX Working Principle

## 1. Start Bit Detection

UART line remains HIGH during idle state.

A transition:

```text
1 -> 0
```

indicates possible start of transmission.

---

## 2. Mid-bit Synchronization

The receiver waits for:

```text
baud / 2
```

clock cycles before sampling the start bit.

This aligns sampling to the center of the bit period for reliable reception.

---

## 3. Serial Data Reception

Incoming serial bits are sampled every:

```text
baud
```

clock cycles and stored into a shift register.

---

## 4. Stop Bit Validation

The receiver validates whether stop bit is HIGH.

If valid:

```verilog
data <= shift_reg[8:1];
```

updates received output data.

---

# Baud Rate Calculation

Baud timing is generated using:

```verilog
localparam baud = clk_freq / baud_rate;
```

Example:

| Parameter            | Value  |
| -------------------- | ------ |
| Clock Frequency      | 10 MHz |
| Baud Rate            | 1 Mbps |
| Clock Cycles per Bit | 10     |

---

# Loopback Verification

The UART transmitter output is directly connected to the UART receiver input:

```verilog
wire serial_line;
```

Connection:

```verilog
.tx(serial_line)
.rx(serial_line)
```

This enables complete UART communication verification within simulation.

---

# Simulation Tools Used

* Verilog HDL
* Icarus Verilog
* GTKWave
* VS Code

---

# Compilation

```bash
iverilog -o sim uart_tx.v uart_rx.v uart_loopback.v uart_loopback_tb.v
```

---

# Run Simulation

```bash
vvp sim
```

---

# Open Waveforms

```bash
gtkwave wave.vcd
```

---

# Example Simulation Output

```text
Received Data 1 = 10110010
Received Data 2 = 11001100
```

This confirms successful UART loopback communication.

---

# Waveform Verification

The simulation verifies:

* UART frame generation
* Start bit transmission
* Serial data transmission
* Stop bit transmission
* RX synchronization
* Serial-to-parallel conversion
* Correct received output data

---

# Concepts Used

* Verilog HDL
* Finite State Machines (FSM)
* Sequential Logic
* Shift Registers
* Serial Communication
* UART Protocol Design
* Baud Rate Timing
* Serial-to-Parallel Conversion
* RTL Design
* Testbench Verification

---

# Future Improvements

Possible future upgrades:

* UART RX Done Signal
* FIFO Buffer Integration
* Parity Bit Support
* Multiple Stop Bits
* Error Detection
* Full Duplex UART
* FPGA Hardware Implementation
* Interrupt-based UART

---

# Project Structure

```text
UART/
│
├── uart_tx.v
├── uart_rx.v
├── uart_loopback.v
├── uart_loopback_tb.v
├── wave.vcd
├── waveform.png
└── README.md
```

---

# Author

**Samarpan Sahu**

