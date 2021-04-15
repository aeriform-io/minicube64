void reset6502();
void exec6502(uint32_t tickcount);
void step6502();
void irq6502();
void nmi6502();

extern uint16_t pc;
extern uint8_t sp, a, x, y, status;
#define FLAG_INTERRUPT 0x04
uint8_t read6502(uint16_t address);
void write6502(uint16_t address, uint8_t value);
