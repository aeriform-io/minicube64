import sys
import csv

def main():

    CYEL = '\33[33m'
    CEND = '\033[0m'
    CRED = '\033[91m'

    arguments = sys.argv[1:]
    count = len(arguments)

    if count < 1:
        print(CYEL+"Please specify a CSV tilemap (mask optional)")
        return

    filename = sys.argv[1]
    
    print()
    
    try:
        f = open(filename, 'r')
    except OSError as e:
        print(CRED+f"Unable to open {filename}: {e}", file=sys.stderr)
        return

    tile=[]

    with open(filename, newline='') as f:
        reader = csv.reader(f)
        data = list(reader)

        for row in data:
            for entry in row:
                # moo.append(entry)
                val = int(entry)

                tile.append(val)

    if count > 1:

        try:
            maskname = sys.argv[2]
            f = open(maskname, 'r')
        except OSError as e:
            print(CRED+f"Unable to open {filename}: {e}", file=sys.stderr)
            return

        mask=[]

        with open(maskname, newline='') as f:
            reader = csv.reader(f)
            data = list(reader)

            for row in data:
                for i in range(len(row)):
                    if row[i] != '-1':
                        row[i] = 128
                    else:
                        row[i] = 0
                    mask.append(row[i])

        data = [x + y for (x, y) in zip(tile, mask)] 
    else:
        print(CYEL+"No mask provided"+CEND)
        print()
        data = tile

    data = [data[x:x+8] for x in range(0, len(data), 8)]

    for row in data:
        print('hex',end=" ")
        for entry in row:
            val = "0x{:02x}".format(int(entry))
            print(CYEL+val[2:4],end=" ")
        print(CEND)
    print()

if __name__ == '__main__':
    main()