#include <MiniFB.h>
#include <stdio.h>
#include <stdlib.h>
#include <stdint.h>
#include <string.h>

#include "fake6502.h"
#include "asm6f.h"
#include "nes_apu.h"
#include "machine.h"

#define MSF_GIF_IMPL
#include "msf_gif.h"

uint32_t gif_frame[64*64];

MsfGifState gifState = {};

#define SOKOL_IMPL
#include "sokol_audio.h"

uint8_t memory[1<<16];
uint8_t default_palette[768];
apu_t *APU=NULL;

#define AUDIO_SAMPLERATE 44100
#define AUDIO_CHANNELS 1
#define AUDIO_SAMPLE_SIZE ((AUDIO_SAMPLERATE/60))

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
	if ((address>=IO_AUDIO_REGS) && (address<=(IO_AUDIO_REGS+0x20)))
	{
		return apu_read(address);
	}

	return memory[address];

}
void write6502(uint16_t address, uint8_t value)
{
	if ((address>=IO_AUDIO_REGS) && (address<=(IO_AUDIO_REGS+0x20)))
	{
		apu_write(address,value);	
	}

//	printf("W8 %x = %x\n",address,value);
	memory[address] = value;	
}

void my_stream_callback(float* buffer, int num_frames, int num_channels)
{
	apu_process(audio_buffer,2048);

	for (int q=0;q<num_frames*num_channels;q++)
	{
		buffer[q]=CLAMP((((float)audio_buffer[q]/32767.0f)),-1.0f,1.0f);
	}
}

void reset_machine(char *fname)
{
char debug_line[256];

	memset(audio_buffer,0,sizeof(audio_buffer));

	for (int i = 0; i < 256*256; ++i)
		memory[i] = 0;

	//	default palette
	for (int q=0;q<240;q++)
	{
		default_palette[(q*3)+2] = (q % 6) * 0x33;
		default_palette[(q*3)+1] = ((q/6) % 6) * 0x33;
		default_palette[(q*3)+0] = ((q/36) % 6) * 0x33;
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
		}
	}
	else 
	{
		printf("nothing to do\n");
		exit(0);
	}
	reset6502();
	pc = 0x200;


	APU=apu_create(0,44100,60,16);
	apu_setcontext(APU);
	apu_reset();
	printf("apu has reset\n");

	msf_gif_begin(&gifState, 64, 64);

	saudio_setup(&(saudio_desc){.stream_cb = my_stream_callback,.num_channels = 1});
}


void display_machine(int g_width,int g_height,uint32_t *g_buffer)
{
	uint8_t paletteblock = read6502(0x101);
	uint8_t *palette = &memory[paletteblock*256];
	if (paletteblock==0)
		palette = &default_palette[0];

	uint8_t vramblock = read6502(0x100);
	uint8_t *vram = &memory[vramblock*4096];
	uint8_t byt;

	exec6502((6400000)/60);
	
	for (int i = 0; i < g_width * g_height; ++i)
	{
		uint8_t byt = vram[i&0xfff];
		int lookup = byt*3;
		g_buffer[i] = MFB_RGB(palette[lookup+2], palette[lookup+1],palette[lookup]); 
		gif_frame[i] = MFB_RGB(palette[lookup], palette[lookup+1],palette[lookup+2]);
	}

#if 0
	for (int i = 0; i < 64; ++i)
	{
		int16_t byt = audio_buffer[i*4];
		float f = CLAMP((((float)byt/32767.0f)),-1.0f,1.0f);

		g_buffer[i+(32+((int)(f*31.0f)))*64] = MFB_RGB(255,255,255); 

	}
#endif
	if ((status & FLAG_INTERRUPT)==0)
	{
		irq6502();
	}

	msf_gif_frame(&gifState,(uint8_t*)&gif_frame[0], 2, 32, g_width*4);
}

void kill_machine()
{	
	MsfGifResult result = msf_gif_end(&gifState);
	FILE * fp = fopen("minicube.gif", "wb");
	fwrite(result.data, result.dataSize, 1, fp);
	fclose(fp);
	msf_gif_free(result);

	apu_destroy(&APU);	
	saudio_shutdown();
}
