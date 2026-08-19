# Tailored processing of ML workloads on Risc-V processors
This repository contains the thesis which focuses on a domain specific 32-bit RISC-V processor optimized for low-power Edge- AI and TinyML workloads. Built on a 5 stage pipelined RV32I core, this implementation integrates single precision floating point and vector extensions, and specialized custom instructions aimed at easing ML algorithm workloads. 

The design is targeted and validated on the AMD Xilinx Artix-7 FPGA (xc7a100tcg324-1), using the Vivado design suite.

## Key Features
- Processing unit: Situated in the execution stage is the processing unit. It consists of the following units:
  - Floating Point Unit (FPU): Following the IEEE 764 standard, the unit is designed to execute operations on single precision floating point operands. The floating point operands share the integer register with the purpose of saving area.
  - Machine Learning Algorithm Unit (MLU): Situated in both the ALU and FPU parts of the processing unit. It handles the dedicated execution of the aforementioned ML algorithm loads, that would otherwise require multiple instructions and hence clock cycles to calculate.
  - Vector Reduction Unit (VRU): This unit handles reduction of multiple elements, that are part of the vector register file.
  - Vector Processing Unit (VPU): The main processing unit that contains multiple instantiations of the ALU, FPU and MLU. It based on the fixed-length SIMD architecture, with VLEN=128 bits and SEW=32, giving processing capabilities with 4 vector elements in a single clock cycle.
- Vector register file
- Flushing control
- Hazard detection and Handling for each integrated data type

## Getting Started
### Prerequisites
- Synthesis and Simulation Tools: AMD Xilinx Vivado Design Suite (2020.2>)
- Software Toolchain: You can use [https://godbolt.org/](Compiler Explorer) to compile your high level code into assembly, which then needs to be converted to fit COE file standards.

### Loading the project
1. Open Vivado and create a project targetting the `sc7a100tcsg324-1`
2. Add all VHDL source file from `extending_riscv/extending_riscv.src/sources_1/new` into the Design Sources
3. Add testbenches from `extending_riscv/extending_riscv.src/sources_1/imports/new`. To run the entire simulation, use `top_test_tb.vhd`
4. Set the top as `top.vhd`
5. Generate the program and data memory, as directed [here](#generating-ip-blocks)
6. Load your own coe file or use one of the example coe file from the `assem_code/`. Ensure you load both the program code and it equivalent data code (usally saved as *_data.coe).
7. Run Behavioral Simulation

### Generating IP Blocks
The program and data memory are generated from IP blocks of the IP catalog. It is created as follows:
1. Open the IP catalog under the Project Manager
2. Locate the IP called `Block Memoery Generator`
3. Based on which memory block you are creating, change the component name to `data_memory` or `instruction_memory`. If you prefer to use your own name, ensure you make the necessary changes in the vhdl code.
4. Ensure the following settings are chosen:
   - Interface Type: Native
   - Memory Type: Single Port RAM for data memory and Single Port ROM for program memory
   - Write Width: 32 bits
   - Depth Width: 1024 or your desired depth, but ensure it will fit your code
   - Operating Mode: Read First
   - Enable Pin: Always enabled
   - Under the Other Option tab, yo ucan check the Load Init File and point to the .coe file to load your assembly code.
5. Click Generate
Ensure you do this twice. Once for the data memory and once for the program memory.
