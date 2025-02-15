# pitch-training-system

## Audio Jack Output (Angus)

Takes PWM audio signals. Project located in `./audio_synthesizer`.

### Done
- Single note playing for any note on piano (adjusting period)
    - Piano notes in terms of period is documented in `./audio_synthesizer/piano_notes.xlsx`
- Volumn adjustment (adjusting duty cycle)
- Playing chords (multiple notes at once)

### TODO
- Packaging/custom IP with AXI interface

### Constraints
- AUD_PWM: PWM driver for audio jack
- AUD_SD: "shutdown active low", basically an enable

```
## PWM Audio Out
set_property -dict { PACKAGE_PIN A11   IOSTANDARD LVCMOS33 } [get_ports { AUD_PWM }];
set_property -dict { PACKAGE_PIN D12   IOSTANDARD LVCMOS33 } [get_ports { AUD_SD }];
```

[VHDL Sample Project Download](https://www.secs.oakland.edu/~llamocca/VHDLforFPGAs.html)

[More sophisticated PWM Implementation](https://zipcpu.com/dsp/2017/09/04/pwm-reinvention.html)


## 7 Segment Display

### Done
- Writing ASCII values into each of the 8x 7-seg displays

### TODO
- Packaging

### Constraints
- SEG7_SEG\[6:0\]: controls segments ABCDEFG of each 7seg (note: 0 = ON)
- SEG7_DP: controls the decimal point of each 7seg (note: 0 = ON)
- SEG7_AN\[7:0\]: common anode, one for each 7seg (note: 0 = ON)

[Digilent Nexys 4 DDR Keyboard Demo](https://github.com/Digilent/Nexys-4-DDR-Keyboard)

