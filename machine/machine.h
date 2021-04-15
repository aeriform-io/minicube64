void reset_machine();
void display_machine(int g_width,int g_height,uint32_t *g_buffer);
void kill_machine();

#define IO_VIDEO 0x100 
#define IO_COLORS 0x101
#define IO_INPUT 0x102
#define IO_AUDIO 0x104
#define IO_AUDIO_REGS 0x110
