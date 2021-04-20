from PIL import Image, ImageSequence
import math
import sys
import os

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

	input = Image.open(basename)
	(w, h) = input.size

	if w>64 or h>64:
		print(CYEL + "WARNING: Images larger than 64x64 will not load." + CEND)

	original_palette = input.getpalette()

	if original_palette==None:
		print(CRED + "ERROR: Image must be indexed." + CEND)
		return

	original_palette = [ tuple(original_palette[i:i+3]) for i in range(0, len(original_palette), 3) ]
	def lum (r,g,b):
		return math.sqrt( .241 * r + .691 * g + .068 * b )
	palette = [ v for v in original_palette ]


	if mode=='default':
		palette.sort(key=lambda rgb: lum(*rgb)    )

	colour_to_index = { palette[i]:	 i for i in range(0, len(palette)) }
	original_index_to_index = { i: colour_to_index[original_palette[i]] for i in range(0, len(palette)) }

	print()
	print(outname)
	print(outclutname)
	print()

	outraw = open(outname, "wb")
	outclut = open(outclutname, "wb")

	for ty in range(0,h):
		for tx in range(0,w):
			p = original_index_to_index[input.getpixel((tx,ty))]
			outraw.write(p.to_bytes(1,byteorder='big'))

	for (r,g,b) in palette:
		outclut.write(r.to_bytes(1,byteorder='big'))
		outclut.write(g.to_bytes(1,byteorder='big'))
		outclut.write(b.to_bytes(1,byteorder='big'))

	outraw.close()
	outclut.close()

if __name__ == '__main__':
   main()
