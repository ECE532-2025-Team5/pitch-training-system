# pitch-training-system

## Audio Jack Output (Angus)

Takes PWM audio signals. Project located in `./audio_synthesizer`.

### Done
- Single note playing for any note on piano (adjusting period)
    - Piano notes in terms of period is documented in `./audio_synthesizer/piano_notes.xlsx`
- Volumn adjustment (adjusting duty cycle)

### TODO
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