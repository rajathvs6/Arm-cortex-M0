# ARM Cortex‑M0 Core (Verilog Implementation)

This project implements a 3-stage ARM Cortex-M0 compatible processor core in Verilog HDL. The design supports a subset of the ARMv6-M instruction set and is developed for behavioral simulation using Xilinx Vivado.

---

## 🚀 Features

- **Architecture**: 3-stage pipeline (Fetch, Decode, Execute)
- **Instruction Set**: Subset of ARMv6-M (arithmetic, logic, memory access, branching)
- **Registers**: 16 general-purpose registers (R0–R15)
- **ALU**: Supports addition, subtraction, bitwise operations, and comparisons
- **Memory**: Separate instruction and data memories (block RAM-based)
- **Simulation**: Testbench provided for verification in Vivado

---

## 🛠️ How to Run (Vivado)

1. **Open Vivado**  
   Launch Vivado and create a new project.

2. **Add Sources**  
   Add all Verilog files under `src/` as design sources and `tb/arm_core_tb.v` as simulation source.

3. **Run Behavioral Simulation**  
   Click **Run Simulation > Run Behavioral Simulation**.  
   Observe waveform, debug using register/memory values.

---

## 📜 Instruction Set (Implemented)

- `ADD`, `SUB`, `MOV`, `CMP`
- `AND`, `ORR`, `EOR`, `LSL`, `LSR`
- `LDR`, `STR` (word-level)
- `B`, `BEQ`, `BNE`, `BLT`, `BGT`

> More instructions can be extended modularly in `control_unit.v` and `alu.v`.

---

## ✅ Testbench

- Initializes registers and memory
- Applies sample instruction stream
- Monitors output via `$display` and waveform analysis
- Validate:
  - Correct ALU operation
  - Memory reads/writes
  - Control flow

---

## 📌 Future Improvements

- Full ARMv6-M instruction support
- Interrupt controller
- Integration with on-chip peripherals
- Pipelining hazard detection (for true pipeline)
- AXI/AHB bus interface

---

## 👤 Author

Rajath
[ARM Cortex-M0 Verilog Project]

---




