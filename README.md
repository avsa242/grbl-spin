grbl-spin
---------

This is a port of the popular open-source CNC controller/G-code interpreter to the SPIN language, for use on the Parallax P8X32A/Propeller MCU

## Salient features

* TBD

## Compiler compatibility

- [x] OpenSpin (tested with version 1.00.81)

## TODO

- [x] Rough port of original C code to SPIN (syntax translation using automated tools, e.g., regex search and replace)
- [ ] Remove C-specific bits from code
- [x] a. Remove prototypes from headers (no linking is done in SPIN)
- [ ] b. Implement a work-alike to C's structures
- [x] Confirm code block ranges/indentation levels (SPIN is indentation-sensitive)
- [ ] Convert unsupported preprocessor extensions (OpenSpin's preprocessor doesn't support all of the same directives that e.g., gcc does, including things such as macros with parameters, complex expressions)
- [ ] Remove Arduino hardware-specific bits, such as pin port masks, interrupts, etc
- [ ] Modify code enough to build successfully
- [ ] Tweak formatting (remove trailing whitespace from auto-conversion, format per spin-std-lib contrib guidelines)


