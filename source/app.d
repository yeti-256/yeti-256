import std.stdio;
import computer;

void main() {
	auto vm = new Computer();

	vm.Load([
		0x07, 0x05, 0x02, // lco r1, 0x02
		0x07, 0x06, 0x02, // lco r2, 0x02
		0x03, 0x05, 0x06, // add r1, r2
		0xFF, 0x00, 0x00  // hlt
	]);

	while (vm.alive) {
		vm.ExcecuteInstruction();
	}

	vm.Dump();
}
