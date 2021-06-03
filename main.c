#include <MiniFB.h>
#include <stdio.h>
#include <stdlib.h>
#include <stdint.h>

#include "machine.h"
#include "fake6502.h"
#include "WindowData.h"

static uint32_t  g_width  = 64*MACHINE_SCALE;
static uint32_t  g_height = 64*MACHINE_SCALE;
uint32_t *g_buffer = 0x0;

///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
static int CalcScale(int bmpW, int bmpH, int areaW, int areaH)
{
	int scale = 0;
	for(;;)
	{
		scale++;
		if (bmpW*scale > areaW || bmpH*scale > areaH)
		{
			scale--;
			break;
		}
	}
	return (scale > 1) ? scale : 1;
}

//	UP 0x109
//	DOWN 0x108
//	LEFT 0x107
//	RIGHT 0x106

mfb_key keys[8] =
{
	0x5a,
	0x58,
	0x43,
	0x101,
	0x109,
	0x108,
	0x107,
	0x106,
};

#define BIT_SET(PIN,N) (PIN |=  (1<<N))
#define BIT_CLR(PIN,N) (PIN &= ~(1<<N))

void
keyboard(struct mfb_window *window, mfb_key key, mfb_key_mod mod, bool isPressed) {
    const char *window_title = "";
    if(window) {
        window_title = (const char *) mfb_get_user_data(window);
    }

		uint8_t kb = read6502(IO_INPUT);
		for (int q=0;q<8;q++)
		{
			if (key==keys[q])
			{
				if (isPressed==true)
					BIT_SET(kb,q);
				else
					BIT_CLR(kb,q);

			}
		}
		write6502(IO_INPUT,kb);

		if (key==0x102)
		{
			if (isPressed==false)
			{
				next_view();
			}
		}
    fprintf(stdout, "%s > keyboard: key: %s (pressed: %d) [key_mod: %x] key %x\n", window_title, mfb_get_key_name(key), isPressed, mod, key);
    if(key == KB_KEY_ESCAPE) {
        mfb_close(window);
    }
}

void
resize(struct mfb_window *window, int width, int height) {
    (void) window;
int scale = 1;
int iw,ih;
int ox,oy;

	scale = CalcScale(g_width,g_height,width,height);
	iw = g_width*scale;
	ih = g_height*scale;
	//	center
	ox = (width-iw)/2;
	oy = (height-ih)/2;
	mfb_set_viewport(window, ox, oy, iw,ih );
}

///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

int main(int argc,char **argv)
{
    struct mfb_window *window = mfb_open_ex("minicube64", g_width, g_height, WF_RESIZABLE);
    if (!window)
        return 0;

    mfb_set_keyboard_callback(window, keyboard);

    g_buffer = (uint32_t *) malloc(g_width * g_height * 4);
    mfb_set_resize_callback(window, resize);

    resize(window, g_width*3, g_height*3);  // to resize buffer

    reset_machine(argv[1]);

    // Manual assignment of draw buffer on window to avoid compatibility issues
    // with X11.
	SWindowData *window_data = (SWindowData *) window;
	window_data->draw_buffer = g_buffer;

    mfb_update_state state;
    do {
        display_machine(window);
        state = mfb_update_ex(window, g_buffer, g_width, g_height);
        if (state != STATE_OK) {
            window = 0x0;
            break;
        }
    } while(mfb_wait_sync(window));

    kill_machine();

    return 0;
}
