#include <stdio.h>
#include <stdint.h>
#include "machine.h"
#include "fake6502.h"

#define MAX_CHANNELS 4

#pragma pack(1)
typedef struct 
{
	uint32_t waveform:8;
	uint32_t volume:8;
	uint32_t frequency:16;
} channel_t;

typedef struct 
{
	uint8_t page;
	uint8_t volume;
	channel_t channels[MAX_CHANNELS];
	uint32_t	samplepos[MAX_CHANNELS];
} chip_t;

chip_t *CHIP;

void wsg_reset(uint8_t *ptr)
{
	int q;
	CHIP = (chip_t*)ptr;
	CHIP->page=0;
	for (q=0;q<MAX_CHANNELS;q++)
	{
		CHIP->samplepos[q] = 0;
		CHIP->channels[q].frequency = 0;
		CHIP->channels[q].volume = 0;
		CHIP->channels[q].waveform = 0;
	}
}

void wsg_play(int16_t* const buffer, int buffer_len)
{
uint16_t sound_ram;

	sound_ram = CHIP->page<<8;
  for (int i = 0; i < buffer_len; i++) {
    int16_t sample = 0;

    for (int voice_no = 0; voice_no < MAX_CHANNELS; voice_no++) {

      if (CHIP->channels[voice_no].frequency == 0 || CHIP->channels[voice_no].volume == 0)
			{
        continue;
      }
      CHIP->samplepos[voice_no] = (CHIP->samplepos[voice_no] + CHIP->channels[voice_no].frequency) & 0xfffff;

      int sample_pos = (CHIP->channels[voice_no].waveform * 32) + ((CHIP->samplepos[voice_no] >> 15)&0x1f);

      int16_t voice_sample = (read6502(sound_ram+sample_pos) - 8) * CHIP->channels[voice_no].volume;
//			int16_t voice_sample = (w->sound_rom[sample_pos] - 8) * v->volume;
      sample += voice_sample;
    }

    *(buffer + i) = sample * ((float)CHIP->volume/16.0f);
  }
}



