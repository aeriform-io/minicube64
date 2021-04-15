
from PIL import Image, ImageSequence
import sys
import os

def main():
	basename = sys.argv[1]
	splitname = basename.split(".")
	outname = splitname[0] + ".raw"
	outclutname = splitname[0] + ".pal"

	input = Image.open(basename)
	(w, h) = input.size
	palette = input.getpalette()


	if w>64 or h>64:
		print("images must be smaller than 64x64")
		return 

	if palette==None:
		print("image must be indexed")
		return 

	print(outname)
	print(outclutname)

	outraw = open(outname, "wb")
	outclut = open(outclutname, "wb")

	for ty in range(0,h):
		for tx in range(0,w):
			p = input.getpixel((tx,ty))
			outraw.write(p.to_bytes(1,byteorder='big'))

	for c in range(0,len(palette),3):
		r = palette[c]
		g = palette[c+1]
		b = palette[c+2]
		# save as bgr
		outclut.write(b.to_bytes(1,byteorder='big'))
		outclut.write(g.to_bytes(1,byteorder='big'))
		outclut.write(r.to_bytes(1,byteorder='big'))

	outraw.close()
	outclut.close()

if __name__ == '__main__':
   main() 		

