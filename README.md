# MIPS 5-Stage Pipelined Processor (32-bit) - Verilog Implementation

This repository contains a complete Verilog implementation of a **32-bit MIPS processor with a classic 5-stage pipeline architecture**. The design mimics real-world MIPS instruction execution using **instruction-level parallelism**, focusing on performance and modularity.  
Ideal for learning processor design, pipelining concepts, and preparing for core VLSI interviews.

---

## Theory Overview

The **MIPS (Microprocessor without Interlocked Pipeline Stages)** architecture is a RISC-based instruction set known for its simplicity and efficiency. The pipelined implementation increases throughput by overlapping instruction execution stages.

### Pipeline Stages:
1. **Instruction Fetch (IF):**  
   
   ![Screenshot 2025-04-12 091624](https://github.com/user-attachments/assets/c45235c3-6f1a-4dde-bbf2-156334658af1)

Fetches instruction from memory using the Program Counter (PC).

2. **Instruction Decode/Register Fetch (ID):**  
   
   ![Screenshot 2025-04-12 091644](https://github.com/user-attachments/assets/59c696fe-8973-4f3f-8aa2-9c691a051dd2)

Decodes the instruction and reads register values.

3. **Execute (EX):**  
   
   ![Screenshot 2025-04-12 091659](https://github.com/user-attachments/assets/b6695a05-4fb2-4bea-9f01-19a637176ec2)

Performs arithmetic or logic operations in the ALU.

7. **Memory Access (MEM):**  
   
   ![Screenshot 2025-04-12 091716](https://github.com/user-attachments/assets/c6899673-3873-4263-80da-75561f4e21e2)

Accesses data memory for load/store instructions.

9. **Write Back (WB):**  
   
   ![Screenshot 2025-04-12 091736](https://github.com/user-attachments/assets/6f00ded0-8cc0-42fd-ae04-55fcbaffd286)

Writes the result back to the register file.


---

##  Features

- ✅ Fully modular Verilog-based design
- ✅ 5-stage pipelining: IF, ID, EX, MEM, WB
- ✅ Support for key R-type, I-type, and load/store instructions
- ✅ ALU Control logic based on `funct` and `ALUOp`
- ✅ Pipeline Registers between all stages
- ✅ Instruction Memory and Data Memory modeled in Verilog
- ✅ Parameterized PC and memory width

---

## Architecture

![Screenshot 2025-04-12 091525](https://github.com/user-attachments/assets/f81a1b38-90f7-4000-bd2c-ed0a1747e2ca)


## 📊 Simulation Results

![Screenshot 2025-04-12 092354](https://github.com/user-attachments/assets/4c0b8503-5455-448a-a588-1c7b4869fcec)

---

## 🔧 Timing Analysis

![Screenshot 2025-04-12 092046](https://github.com/user-attachments/assets/b18eaaad-f0da-409e-b657-3abfa7ddae33)

---

## 🔋 Power Analysis

![Screenshot 2025-04-12 092333](https://github.com/user-attachments/assets/c5884ac0-dcaa-4cfe-b06a-a06ff9ed4ebf)

---
