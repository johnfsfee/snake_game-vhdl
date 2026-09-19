# FPGA snake game (partial logic)
A hardware implementation of the classic Snake Game in VHDL made in under 2 weeks, driving a VGA monitor via a PS/2 keyboard. Because of time constraints, the game is missing the snake's tail.

## System Archtecture
    * `snakegame.vhd` - Top-level architecture.
    * `vga.vhd` - VGA controller
    * `game_controller.vhd` - Game logic
    * `ps2_keyboard.vhd` and `debounce.vhd - Peripheral controls

## Credits & License
This project integrates third-party modules:
    * `debounce.vhd` and `ps2_keyboard.vhd` - Originally authored by Scott Larson (Digi-Key Electronics). Licensed under the original terms included in the source files.

All integration logic, top-level architecture, and system design were implemented by me.
