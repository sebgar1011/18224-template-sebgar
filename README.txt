18-224 S23 Tapeout Template
-------------------

- Add your verilog source files to `source_files` in `info.yaml`
    - The top level of your chip should remain in `chip.sv` and be named `my_chip`

- Optionally add other details about your project to `info.yaml` as well (this is only for GitHub - your final project submission will involve submitting these in a different format)

- Do NOT make any edits to `toplevel_chip.v`
- Do NOT edit `config.tcl` or `pin_order.cfg`

- Your design must synthesize at 2 MHz but you can run it at any arbitrarily-slow frequency (including single-stepping the clock) on the manufactured chip
    - If your design must run at an exact frequency, it is safest to choose a frequency below 500kHz to minimize risk

- If you would like your design to be tested after integration, please provide a plaintext file in your repo with detailed instructions on how to test your design (along with any necessary scripts, testbenches, or automation)

