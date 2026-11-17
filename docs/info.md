## How it works

SPI peripheral that controls 16 outputs. You send 16-bit writes over SPI (SCLK on ui[0], COPI on ui[1], nCS on ui[2]). First bit is read/write, next 7 are the address, last 8 are the data.

Registers:
- 0x00: output enable for uo_out[7:0]
- 0x01: output enable for uio_out[7:0]
- 0x02: PWM enable for uo_out[7:0]
- 0x03: PWM enable for uio_out[7:0]
- 0x04: PWM duty cycle

Each output can be off, on, or PWM at about 3 kHz.

## How to test

Run the cocotb tests in the test folder. They send SPI writes and check the outputs.

## External hardware

None