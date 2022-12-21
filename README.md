# yeti-256
really simple

## Specifications
```
Memory layout:
(Bank 0) 0x00         - options
(Bank 0) 0x01 to 0xFF - general purpose memory
(Bank 1) 0x00 to 0xFF - video memory
(Bank 2) 0x00 to 0xFF - data lines for all ports
(Bank 3) 0x00 to 0xFF - stack
(Bank 4) 0x00 onwards - start of program
Rest of memory        - general purpose memory
```

```
Instructions:
(0x00) NOP (unused) (unused)      - do nothing at all
(0x01) LDA (addr in reg) (unused) - load data from memory into accumulator
(0x02) STO (addr in reg) (reg)    - store contents of accumulator at addr
(0x03) ADD (reg) (reg)            - add the contents of both registers and store in ac
(0x04) SUB (reg) (reg)            - add the contents of both registers and store in ac
(0x05) MUL (reg) (reg)            - add the contents of both registers and store in ac
(0x06) DIV (reg) (reg)            - add the contents of both registers and store in ac
(0x07) LCO (reg) (constant)       - load constant value into register
(0x08) CRV (reg des) (reg src)    - copy contents of reg src into reg dest
(0x09) CLO (reg) (constant)       - conditional LCO, executes if ac is non-zero
(0x0A) AND (reg) (reg)            - bitwise AND
(0x0B) NOT (reg) (unused)         - bitwise NOT
(0x0C) XOR (reg) (reg)            - bitwise XOR
(0x0D) ORR (reg) (reg)            - bitwise OR
(0xFF) HLT (unused) (unused)      - shut down the VM   
```
