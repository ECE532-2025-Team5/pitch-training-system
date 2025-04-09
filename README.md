# Configuration of microphones
This branch hosts 1 succssful attempt in configuring the onboard microphone on Nexys 4 DDR board and 2 failed attempt in configuring Pmod MIC3 and explanation on why it failed. 

## Configuration of onboard microhpne
correct.v file hosts a successful configuration of onboard microphone.

### Features

- ⚙️ **Clock Downsampling**  
  Downsamples the 100 MHz system clock to generate a 2.5 MHz sampling clock for the microphone (`mic_clk` output).

- 🎛️ **PDM to PWM Conversion**  
  - Uses **20 parallel counters** to accumulate the PDM signal into an 8-bit PWM value.
  - Each accumulation lasts for **128 microphone clock cycles**.
  - A threshold mechanism ensures that each PWM signal is emitted **6–7 mic_clk cycles apart**.

- ⏱️ **Audio Sampling Downrate**  
  While PWM is being transmitted, the module employs a `case`-based state machine to downsample the audio signal to a **19.5 kHz** rate for stable output.

- 🔈 **Audio Output**  
  - The processed PWM signal is output through the `AUD_PWM` pin.
  - The `AUD_SD` pin is tied high/low to control the amplifier switch.

Detailed reason of why such implementation is ideal, can consult the Nexys 4 DDR reference manual(https://digilent.com/reference/_media/nexys4-ddr:nexys4ddr_rm.pdf?srsltid=AfmBOoqQkK3gS_t9WGwNpmnmbsqvSeyXRPJ0KoJU0D0wcz0bkj4z8rA8). It uses a design of 2 counters that samples from microphone to explain such implementation. 

## Configuration of Pmod MIC3

Two attempts had been tried to configure this Pmod. 

### 🔧 First Attempt: Using the Pmod MIC3 IP Library

- **Source:**  
  [Digilent Forum Thread – Pmod MIC3 with Zynq](https://forum.digilent.com/topic/20141-pmod-mic3-with-zynq-through-zedboard/)

- **Description:**  
  This IP core is not an official release from Digilent but was shared by a technical moderator who successfully used it to produce a sine wave output in a terminal (Tera Term).

- **Test Results:**  
  - UARTLite terminal prints showed higher ADC values when loud sounds were detected, and lower values in quiet environments.
  - However, converting the ADC output into audio using the official Digilent PWM block (downloaded from https://github.com/Digilent/vivado-library) resulted in unusable sound. This outputs only a fluctuating monotone beep, with volume changes based on microphone input levels.

- **Issue:**  
  - Direct usage of this IP failed to compile in **Xilinx SDK (Vivado 2018.3)** due to unresolved linker errors.
  - Debugging the problem requires an in-depth understanding of the Xilinx SDK internals, which is **not recommended** unless you're highly experienced.

- **💡 Workaround:**  
  Refer to [this Digilent Forum workaround](https://forum.digilent.com/topic/21972-pmod-mic3/) to bypass the linker issue:
  - Use the official **Pmod DPG IP block** instead (available in the same release as the PWM block).
  - Copy `PmodMIC3.c` and `PmodMIC3.h` from the MIC3 IP source:
    - `PmodMIC3_v1_0/drivers/PmodMIC3_v1_0/src`
  - Paste them in `PmodDPG1.c` and `PmodDPG1.h` in:
    - `PmodDPG1_v1_0/drivers/PmodDPG1_v1_0/src`
  - Since both MIC3 and DPG use the **same ADC, pin layout, and SPI protocol**, this workaround works for compiling and running the code.

---

### 🧪 Second Attempt: Using Verilog Source Code from GitHub

- **Source:**  
  [GitHub Repository – suoglu/Pmod](https://github.com/suoglu/Pmod)

- **Description:**  
  This repository contains Verilog modules for various Pmods, including MIC3. The modules were reportedly validated in both simulation and physical implementation by the repository author.

- **Considerations:**  
  - While the source provides a good starting point, **updates or modifications may be necessary**.
  - Simulation and implementation behaviors may differ, and some inconsistencies were observed in this project.
  - Treat this repository as a **reference** rather than a drop-in solution.

---