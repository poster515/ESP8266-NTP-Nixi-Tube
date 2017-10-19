# ESP8266 and Nixi Tubes

This repository contains all the files necessary to hook up an Altera FPGA to an Adafruit Huzzah.


The Huzzah board connects to my Wifi, and retrieves NTP packets roughly every one second.

The Huzzah then sends time information to the Altera board as follows:

| 8-bit hour register addr | 8-bit hour data | 8-bit min reg addr | 8-bit min data | 8-bit sec reg addr | 8-bit sec data |


The Altera board processes this data, which is just three unsigned integers, and converts each to two, 4-bit outputs. For example, if hours = 15, the Altera board generates two new outputs, hours_1 and hours_0, each 4 bits wide. In this example, hours_1 = 1 and hours_0 = 5. 

These six, 4-bit outputs are used to control CD4028 high-voltage decoders, which then control Nixi tubes.
Altera FPGA Decoder Simulation Results:

[[ESP8266-NTP-Nixi-Tube/pics/sim_results.png]]

Altera FPGA Overall Simulation Results:

[[./pics/main_DSP_sim.png]]

And there you have it!

An NTP enabled Nixi Tube clock. 

//TODO: will investigate spurious freezing of the Altera board.
 
