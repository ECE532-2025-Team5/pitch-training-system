# pitch-training-system

## Audio Jack Output

Takes PWM audio signals.

Constraints:
- AUD_PWM: PWM driver for audio jack
- AUD_SD: "shutdown active low", basically an enable

```
##PWM Audio Amplifier

set_property -dict { PACKAGE_PIN A11   IOSTANDARD LVCMOS33 } [get_ports { AUD_PWM }]; #IO_L4N_T0_15 Sch=aud_pwm
set_property -dict { PACKAGE_PIN D12   IOSTANDARD LVCMOS33 } [get_ports { AUD_SD }]; #IO_L6P_T0_15 Sch=aud_sd
```

[VHDL Sample Project Download](https://www.secs.oakland.edu/~llamocca/VHDLforFPGAs.html)

[More sophisticated PWM Implementation](https://zipcpu.com/dsp/2017/09/04/pwm-reinvention.html)