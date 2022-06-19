# OSVVM Demonstrator

A VHDL project demonstrating how to use the [OSVVM library](https://osvvm.org/) to check the correct operation of an [airhdl](https://airhdl.com) register bank.

![Demonstrator architecture](./doc/osvvm-demo.png)

## Architecture

The toplevel component instantiates an airhdl register bank, `osvvm_regs`, which contains two registers:

* a read/write `Control` register with a 16-bit `value` field   
* a read-only `Status` register with a 16-bit `value` field

The `Control.value` output port of the register bank, which reflects the current value of the `Control.value` field, 
is looped back to the `Status.value` input port, which represents the value to be read from the `Status.value` field.

The `Axi4LiteManager` component, which is part of the OSVVM library, acts as a AXI4-Lite master. It is controlled by the Test Controller (`tb_osvvm_regs_testctrl`) through a standard OSVVM transaction record signal.

Following the standard OSVVM pattern, test cases are implemented as alternative architectures of the Test Controller component. The design currently features the following test cases:

| Test case | Source file | Description |
| --------- | ----------- | ----------- |
| `operation` | `tb_osvvm_regs_operation.vhd` | Normal operation test case. Writes a test pattern to the `Control.value` field and checks that the value can be read back through the `Status.value` field. |

## Running the Simulation

To run the OSVVM test suite, execute the following commands in the simulator console:

```
cd sim
source ../lib/OsvvmLibraries/Scripts/StartUp.tcl
build ../lib/OsvvmLibraries
build ../RunAllTests.pro
```

If the test suite completes succesfully, you should see something like this in the simulator console:

```
# KERNEL: %% Log   ALWAYS  in Default, Write Control register at 76 ns
# KERNEL: %% Log   INFO    in Axi4LiteManager, Write Data.  WData: 00001234  WStrb: 1111  Operation# 1 at 85 ns
# KERNEL: %% Log   INFO    in Axi4LiteManager, Write Address.  AWAddr: A0000000  AWProt: 000  Operation# 1 at 85 ns
# KERNEL: %% Log   ALWAYS  in Default, Read Status register at 105 ns
# KERNEL: %% Log   INFO    in Axi4LiteManager, Read Address.  ARAddr: A0000000  ARProt: 000  Operation# 1 at 105 ns
# KERNEL: %% Log   INFO    in Axi4LiteManager, Read Data: 00001234  Read Address: A0000000  Prot: 0 at 145 ns
# KERNEL: %% DONE  PASSED  tb_osvvm_regs_operation  Passed: 3  Affirmations Checked: 3  at 145 ns
```

## Acknowledgments

Many thanks to:

* **Jim Lewis** of [SynthWorks Design Inc.](https://www.synthworks.com/) for the OSVVM support.
* **[Sigasi](https://www.sigasi.com/)** for providing a Sigasi Studio XPRT license, which was of great help for implementing this project.
