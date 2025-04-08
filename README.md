# pitch-training-system

## MAIN PROJECT
### Project
`./MEMES_mic/MEMS_mic.xpr`
### Project as IP
`./PitchTrainingSystem_ip`
### Project Bitstream
`./PitchTrainingSystem_bitstream`
## PERIPHERALS (Angus)
Logic in `./system_software` project.

Dependencies:
- Top Level (`./integration/piano_with_software/swctrl_piano.v`)
    - piano (`./integration/piano_with_software/piano.v`)
        - Keyboard input (`./keyboard/keyboard.v`), with passthrough to module output
        - Custom PS2/ASCII library (`./keyboard/ps2_to_ascii.v`)
              - **MUST SET THIS TO GLOBAL INCLUDE**
        - Piano Keyboard from Keyboard (`./keyboard/kb2piano_octave.v`)
        - Audio (`./audio/piano/piano_octave.v`)
            - Piano Note (`./audio/piano/piano_note.v`)
                - Audio Jack (`./audio/freq_pwm/freq_pwm.v`)
    - 7seg (`./7seg/seg7x8.v`)

## Audio Jack Output (Angus)

Takes PWM audio signals. Project located in `./audio_synthesizer`.

### Done
- Single note playing for any note on piano (adjusting period)
    - Piano notes in terms of period is documented in `./audio_synthesizer/piano_notes.xlsx`
- Volumn adjustment (adjusting duty cycle)
- Playing chords (multiple notes at once)

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


## 7 Segment Display (Angus)

Made a custom module to display all ASCII values. However if one only need to display hex values \[0-F\], you may use [reference 7seg module](https://github.com/Digilent/Nexys-4-DDR-Keyboard/blob/master/src/hdl/Seg_7_Display.v)

### Done
- Writing ASCII values into each of the 8x 7-seg displays

### TODO
- storing 8 bit segment representation as inputs, then have module handle display logic

### Constraints
- SEG7_SEG\[6:0\]: controls segments ABCDEFG of each 7seg (note: 0 = ON)
- SEG7_DP: controls the decimal point of each 7seg (note: 0 = ON)
- SEG7_AN\[7:0\]: common anode, one for each 7seg (note: 0 = ON)

[Digilent Nexys 4 DDR Keyboard Demo](https://github.com/Digilent/Nexys-4-DDR-Keyboard)


## PS/2 Keyboard (via USB-A) (Angus)

### Done
- Getting the keycode from each key in PS2 keyboard

[PS/2 Keycodes](https://www.eecg.utoronto.ca/~pc/courses/241/DE1_SoC_cores/ps2/ps2.html#apkeycodes)
