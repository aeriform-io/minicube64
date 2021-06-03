#include <MiniFB.h>
#include <stdio.h>
#include <stdlib.h>
#include <stdint.h>
#include <string.h>

#include "fake6502.h"
#include "asm6f.h"
#include "wsg.h"
#include "machine.h"
#include "MiniFB_prim.h"

#define MSF_GIF_IMPL
#include "msf_gif.h"

uint32_t gif_frame[(64*MACHINE_SCALE)*(64*MACHINE_SCALE)];

MsfGifState gifState = {};

#define SOKOL_IMPL
#include "sokol_audio.h"

uint8_t memory[1<<16];
uint8_t default_palette[768];
int debug_view = 0;


#ifdef NES_APU
#include "nes_apu.h"
apu_t *APU=NULL;

#define AUDIO_SAMPLERATE 44100
#define AUDIO_CHANNELS 1
#define AUDIO_SAMPLE_SIZE ((AUDIO_SAMPLERATE/60))
#endif

#define CLAMP(x, a, b)    ((x) < (a) ? (a) : (x) > (b) ? (b) : (x))

int16_t audio_buffer[2048];

unsigned char *disk_load_to(const char *fname,unsigned char *buffer)
{
	FILE *fp = fopen(fname,"rb");

	if (fp!=NULL)
	{
		fseek(fp,0,SEEK_END);
		int len = ftell(fp);
		fseek(fp,0,SEEK_SET);
		fread(buffer,len,1,fp);
		fclose(fp);
		return buffer;
	}
	fprintf(stderr,"File failed %s\n",fname);
	return NULL;
}


uint8_t read6502(uint16_t address)
{
#ifdef NES_APU
	if ((address>=IO_AUDIO_REGS) && (address<=(IO_AUDIO_REGS+0x20)))
	{
		return apu_read(address);
	}
#endif
	return memory[address];

}
void write6502(uint16_t address, uint8_t value)
{
#ifdef NES_APU
	if ((address>=IO_AUDIO_REGS) && (address<=(IO_AUDIO_REGS+0x20)))
	{
		apu_write(address,value);
	}
#endif
//	printf("W8 %x = %x\n",address,value);
	memory[address] = value;
}

void my_stream_callback(float* buffer, int num_frames, int num_channels)
{
#ifdef NES_APU
	apu_process(audio_buffer,2048);
#else
	wsg_play(audio_buffer, 2048);
#endif

	for (int q=0;q<num_frames*num_channels;q++)
	{
		buffer[q]=CLAMP((((float)audio_buffer[q]/32767.0f)),-1.0f,1.0f);
	}
}

void reset_machine(char *fname)
{
char debug_line[256];

	debug_view = 0;
	memset(audio_buffer,0,sizeof(audio_buffer));

	for (int i = 0; i < 256*256; ++i)
		memory[i] = 0;

	//	default palette
	for (int q=0;q<240;q++)
	{
		default_palette[(q*3)+0] = (q % 6) * 0x33;
		default_palette[(q*3)+1] = ((q/6) % 6) * 0x33;
		default_palette[(q*3)+2] = ((q/36) % 6) * 0x33;
	}


	if (fname!=NULL)
	{
		char *ptr=strstr(fname,".s");
		if (ptr!=NULL)
		{
			sprintf(debug_line,"%s",fname);
			ptr=strstr(debug_line,".s");
			*ptr++='.';
			*ptr++='b';
			*ptr++='i';
			*ptr++='n';
			*ptr = 0;
			cpu_asmfile(fname);
			disk_load_to(debug_line,&memory[0x200]);
		}
		else {
			ptr=strstr(fname,".bin");
			if (ptr!=NULL)
			{
				sprintf(debug_line,"%s",fname);
				disk_load_to(debug_line,&memory[0x200]);
			}
			else {
				printf("FILE NOT FOUND.\n");
				disk_load_to("boot.bin",&memory[0x200]);
			}
		}
	}
	else
	{
		printf("NO CART LOADED.\n");
		disk_load_to("boot.bin",&memory[0x200]);
	}
	reset6502();
	pc = 0x200;


#ifdef NES_APU
	APU=apu_create(0,44100,60,16);
	apu_setcontext(APU);
	apu_reset();
	printf("apu has reset\n");
#else
	wsg_reset(&memory[IO_AUDIO_REGS]);
#endif

	msf_gif_begin(&gifState, (64*MACHINE_SCALE), (64*MACHINE_SCALE));

	saudio_setup(&(saudio_desc){.stream_cb = my_stream_callback,.num_channels = 1});
}

void next_view()
{
	debug_view++;
}

void display_machine()
{
	int i=0;
	uint8_t paletteblock = read6502(0x101);
	uint8_t *palette = &memory[paletteblock*256];
	if (paletteblock==0)
		palette = &default_palette[0];

	uint8_t vramblock = read6502(0x100);
	uint8_t *vram = &memory[vramblock*4096];
	uint8_t byt;

	exec6502((6400000)/60);

	debug_view&=1;

	if (debug_view==0)
	{
		//	scaled up no debug
		i = 0;
		for (int y=0;y<64;y++)
		{
			for (int x=0;x<64;x++)
			{
				uint8_t byt = vram[i&0xfff];
				int lookup = byt*3;
				mfb_rect_fill(x*MACHINE_SCALE,y*MACHINE_SCALE,MACHINE_SCALE,MACHINE_SCALE,MFB_RGB(palette[lookup], palette[lookup+1],palette[lookup+2]));
				i++;
			}
		}
	}

	if (debug_view==1)
	{
		// 	scaled down with debug
		mfb_rect_fill(0,0,(64*MACHINE_SCALE),(64*MACHINE_SCALE),0x00101010);

		i = 0;
		for (int y=0;y<64;y++)
		{
			for (int x=0;x<64;x++)
			{
				uint8_t byt = vram[i&0xfff];
				int lookup = byt*3;

				mfb_setpix(((64*MACHINE_SCALE)-64)+x,y,MFB_RGB(palette[lookup], palette[lookup+1],palette[lookup+2]));
				i++;
			}
		}

		char regs_line[256];
		uint8_t v = read6502(IO_VIDEO);
		uint8_t kb = read6502(IO_INPUT);
		sprintf(regs_line,"%04X SP:%02X A:%02X X:%02X Y:%02X VP:%X P1:%02X", pc,sp,a,x,y,v,kb);
		mfb_print(0,0,MFB_RGB(0,255,255),regs_line);

		uint8_t addr = 0;
		for (int y=72;y<200;y+=8)
		{
			for (int x=99;x<64*MACHINE_SCALE;x+=10)
			{
				char regs_line[256];
				uint8_t zp = memory[addr];
				sprintf(regs_line,"%02X", zp);
				if (zp==0) {
					mfb_print(x,y,MFB_RGB(64,64,64),"--");
				} else {
					mfb_print(x,y,MFB_RGB(255,255,255),regs_line);
				}
				addr++;
			}
		}

		uint16_t npc = pc;

		for (int y=8;y<64*MACHINE_SCALE;y+=8)
		{
			char debug_line[256];
			uint16_t len = disasm6502(npc,debug_line,256);

			mfb_print(0,y,MFB_RGB(255,255,255),debug_line);
			npc+=len;
		}

		for (int i = 0; i < 256; ++i)
		{
			int16_t byt = audio_buffer[i*8];
			float f = CLAMP((((float)byt/32767.0f)),-1.0f,1.0f);
			mfb_setpix(i,
									222+f*32.0f,
									MFB_RGB(255,255,255));
		}
	}

	//	save gif
	if (vramblock!=0)
	{
		i=0;
		for (int y=0;y<64*MACHINE_SCALE;y++)
		{
			for (int x=0;x<64*MACHINE_SCALE;x++)
			{
				uint32_t p = mfb_getpix(x,y);
				uint8_t r = p & 0xFF;
				uint8_t g = p >> 8 & 0xFF;
				uint8_t b = p >> 16 & 0xFF;
				uint8_t a = p >> 24 & 0xFF;
				gif_frame[i] = b | g << 8 | r << 16 | a << 24;
				i++;
			}
		}
		msf_gif_frame(&gifState,(uint8_t*)&gif_frame[0], 2, 32, (64*MACHINE_SCALE)*4);
	}
	
	if ((status & FLAG_INTERRUPT)==0)
	{
		irq6502();
	}

}

void kill_machine()
{
	MsfGifResult result = msf_gif_end(&gifState);
	FILE * fp = fopen("minicube.gif", "wb");
	fwrite(result.data, result.dataSize, 1, fp);
	fclose(fp);
	msf_gif_free(result);
#ifdef NES_APU
	apu_destroy(&APU);
#endif
	saudio_shutdown();
}
