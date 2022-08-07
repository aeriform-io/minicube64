import math
import sys
import os

from PIL import Image


def main():
    basename = sys.argv[1]
    splitname = basename.split(".")
    outname = splitname[0] + ".raw"
    outclutname = splitname[0] + ".pal"
    CRED = '\033[91m'
    CYEL = '\33[33m'
    CEND = '\033[0m'
    try:
        mode = sys.argv[2]
        print(CYEL + "NOTE: Palette will be unsorted." + CEND)
    except:
        mode = "default"

    image = Image.open(basename)
    (w, h) = image.size

    if w>64:
        print(CYEL + "WARNING: Images wider 64 pixels are not advised." + CEND)

    original_palette = image.getpalette()

    if original_palette==None:
        print(CRED + "ERROR: Image must be indexed." + CEND)
        return

    original_palette = [ tuple(original_palette[i:i+3]) for i in range(0, len(original_palette), 3) ]
    def lum (r,g,b):
        return math.sqrt( .241 * r + .691 * g + .068 * b )

    palette = []
    rgb_image = image.convert('RGB')
    for y in range(h):
        for x in range(w):
            rgb = rgb_image.getpixel((x, y))
            if rgb not in palette:
                palette.append(rgb)

    if mode=='default':
        palette.sort(key=lambda rgb: lum(*rgb)    )

    colour_to_index = { palette[i]:     i for i in range(0, len(palette)) }
    original_index_to_index = { i: colour_to_index[original_palette[i]] for i in range(0, len(palette)) }

    print()
    print(outname)
    print(outclutname)
    print()
    print('Palette:')

    outraw = open(outname, "wb")
    outclut = open(outclutname, "wb")

    for ty in range(0,h):
        for tx in range(0,w):
            p = original_index_to_index[image.getpixel((tx,ty))]
            outraw.write(p.to_bytes(1,byteorder='big'))

    for i in range(len(palette)):
        (r,g,b) = palette[i]
        print('hex #%02x%02x%02x ;%02x' % (r, g, b, i))
        outclut.write(r.to_bytes(1,byteorder='big'))
        outclut.write(g.to_bytes(1,byteorder='big'))
        outclut.write(b.to_bytes(1,byteorder='big'))

    outraw.close()
    outclut.close()
    print()

if __name__ == '__main__':
   main()
