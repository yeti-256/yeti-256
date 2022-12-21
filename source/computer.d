import std.conv;
import std.stdio;
import std.algorithm;

enum Registers {
	bk = 0,  // Bank
	pb = 1,  // Program Bank
	pc = 2,  // Program Counter
	sp = 3,  // Stack Pointer
	ac = 4,  // Accumulator
	r1 = 5,  // General purpose register
	r2 = 6,  // General purpose register
	r3 = 7,  // General purpose register
	r4 = 8,  // General purpose register
	r5 = 9,  // General purpose register
	r6 = 10, // General purpose register
	r7 = 11, // General purpose register
	r8 = 12, // General purpose register

	len
}

enum Instructions {
	nop = 0x00,
	lda = 0x01,
	sto = 0x02,
	add = 0x03,
	sub = 0x04,
	mul = 0x05,
	div = 0x06,
	lco = 0x07,
	crv = 0x08,
	and = 0x0A,
	not = 0x0B,
	xor = 0x0C,
	orr = 0x0D,
	jmp = 0x0E,
	jnz = 0x0F,
	hlt = 0xFF
}

class Computer {
	ubyte[256][256]      mem; // Array of memory banks
	ubyte[Registers.len] reg;
	bool                 alive;
	bool                 increment;

	this() {
		alive             = true;
		increment         = true;
		reg[Registers.pb] = 4;
	}

	void Load(ubyte[] program) {
		size_t i = 0;
		foreach (ref b ; program) {
			mem[reg[Registers.bk]][i] = b;
			++ i;
			if (i >= 256) {
				++ reg[Registers.bk];
				i = 0;
			}
		}
	}

	ubyte CurrentProgramByte() {
		return mem[reg[Registers.pb]][reg[Registers.pc]];
	}

	ubyte GetParameter(ubyte offset) {
		ubyte bank = reg[Registers.pb];
		ubyte addr = reg[Registers.pc];
		if ((cast (int) addr) + offset > 255) {
			++ bank;
			addr = cast (ubyte) (((cast (int) addr) + offset) - 256);
		}
		else {
			addr += offset;
		}

		return mem[bank][addr];
	}

	ubyte[]* CurrentMemorySector() {
		return cast(ubyte[]*) (&mem[reg[Registers.bk]]);
	}

	static void CheckValidRegister(ubyte reg) {
		if (reg >= Registers.len) {
			throw new Exception("Invalid register " ~ text(reg), __FILE__, __LINE__);
		}
	}

	void ExcecuteInstruction() {
		switch (CurrentProgramByte()) {
			case Instructions.nop: {
				break;				
			}
			case Instructions.lda: {
				CheckValidRegister(GetParameter(1));
				
				reg[Registers.ac] = mem[reg[Registers.bk]][reg[GetParameter(1)]];
				break;
			}
			case Instructions.sto: {
				CheckValidRegister(GetParameter(1));
				CheckValidRegister(GetParameter(2));
				
				mem[reg[GetParameter(1)]] = reg[GetParameter(2)];
				break;
			}
			case Instructions.add: {
				CheckValidRegister(GetParameter(1));
				CheckValidRegister(GetParameter(2));
				
				reg[Registers.ac] = cast(ubyte) (
					reg[GetParameter(1)] + reg[GetParameter(2)]
				);
				break;
			}
			case Instructions.sub: {
				CheckValidRegister(GetParameter(1));
				CheckValidRegister(GetParameter(2));
				
				reg[Registers.ac] = cast(ubyte) (
					reg[GetParameter(1)] - reg[GetParameter(2)]
				);
				break;
			}
			case Instructions.mul: {
				CheckValidRegister(GetParameter(1));
				CheckValidRegister(GetParameter(2));
				
				reg[Registers.ac] = cast(ubyte) (
					reg[GetParameter(1)] * reg[GetParameter(2)]
				);
				break;
			}
			case Instructions.div: {
				CheckValidRegister(GetParameter(1));
				CheckValidRegister(GetParameter(2));
				
				reg[Registers.ac] = cast(ubyte) (
					reg[GetParameter(1)] / reg[GetParameter(2)]
				);
				break;
			}
			case Instructions.lco: {
				CheckValidRegister(GetParameter(1));

				reg[GetParameter(1)] = GetParameter(2);
				break;
			}
			case Instructions.crv: {
				CheckValidRegister(GetParameter(1));
				CheckValidRegister(GetParameter(2));

				reg[GetParameter(1)] = reg[GetParameter(2)];
				break;
			}
			case Instructions.and: {
				CheckValidRegister(GetParameter(1));
				CheckValidRegister(GetParameter(2));

				reg[Registers.ac] = reg[GetParameter(1)] & reg[GetParameter(2)];
				break;
			}
			case Instructions.not: {
				CheckValidRegister(GetParameter(1));

				reg[Registers.ac] = cast(ubyte) ~reg[GetParameter(1)];
				break;
			}
			case Instructions.xor: {
				CheckValidRegister(GetParameter(1));
				CheckValidRegister(GetParameter(2));

				reg[Registers.ac] = reg[GetParameter(1)] ^ reg[GetParameter(2)];
				break;
			}
			case Instructions.orr: {
				CheckValidRegister(GetParameter(1));
				CheckValidRegister(GetParameter(2));

				reg[Registers.ac] = reg[GetParameter(1)] | reg[GetParameter(2)];
				break;
			}
			case Instructions.jmp: {
				reg[Registers.pb] = GetParameter(1);
				reg[Registers.pc] = GetParameter(2);
				increment         = false;
				break;
			}
			case Instructions.jnz: {
				if (reg[Registers.ac] != 0) {
					reg[Registers.pb] = GetParameter(1);
					reg[Registers.pc] = GetParameter(2);
					increment         = false;
				}
				break;
			}
			case Instructions.hlt: {
				alive = false;
				return;
			}
			default: {
				// TODO: error
			}
		}

		// increment
		//writefln("Before: pb = %d, pc = %d", reg[Registers.pb], reg[Registers.pc]);
		if (increment) {
			if ((cast (int) reg[Registers.pc]) + 3 > 255) {
				++ reg[Registers.pb];
				reg[Registers.pc] =
					cast (ubyte) (((cast (int) reg[Registers.pc]) + 3) - 256);
			}
			else {
				reg[Registers.pc] += 3;
			}
		}
		else {
			increment = true;
		}
		//writefln("After: pb = %d, pc = %d", reg[Registers.pb], reg[Registers.pc]);
	}

	void Dump() {
		write(
			"YETI-256 DUMP\n" ~
			"=============\n" ~
			"bk = " ~ text(reg[Registers.bk]) ~ "\n" ~
			"pb = " ~ text(reg[Registers.pb]) ~ "\n" ~
			"pc = " ~ text(reg[Registers.pc]) ~ "\n" ~
			"sp = " ~ text(reg[Registers.sp]) ~ "\n" ~
			"ac = " ~ text(reg[Registers.ac]) ~ "\n" ~
			"r1 = " ~ text(reg[Registers.r1]) ~ "\n" ~
			"r2 = " ~ text(reg[Registers.r2]) ~ "\n" ~
			"r3 = " ~ text(reg[Registers.r3]) ~ "\n" ~
			"r4 = " ~ text(reg[Registers.r4]) ~ "\n" ~
			"r5 = " ~ text(reg[Registers.r5]) ~ "\n" ~
			"r6 = " ~ text(reg[Registers.r6]) ~ "\n" ~
			"r7 = " ~ text(reg[Registers.r7]) ~ "\n" ~
			"r8 = " ~ text(reg[Registers.r8]) ~ "\n"
		);
	}
}
