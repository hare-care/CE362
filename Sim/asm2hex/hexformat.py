import sys
#format the hexadecimal data
def format_hex_file(input_file, output_file):
    """
    Reads a hex data file, formats the data by grouping the hex digits into pairs, 
    and writes the formatted data to an output file.

    Args:
    input_file (str): Path to the input file containing hex data.
    output_file (str): Path to the output file where the formatted data will be written.
    """
    with open(input_file, 'r') as infile, open(output_file, 'w') as outfile:
        #process every line of data
        for line in infile:
            formatted_line = ' '.join(line[i:i+2] for i in range(0, len(line.strip()), 2))
            outfile.write(formatted_line + '\n')
        # Process the last line and add '00 00 00 00'
        last_line = line[-1]
        formatted_last_line = ' '.join(last_line[i:i+2] for i in range(0, len(last_line.strip()), 2))
        formatted_last_line += '00 00 00 00'  # Add the additional zeros, for the simulation exit
        outfile.write(formatted_last_line + '\n')

def main():
    if len(sys.argv) != 3:
        print("Usage: python pythonscript.py input.hex output.hex")
        sys.exit(1)

    input_file = sys.argv[1]
    output_file = sys.argv[2]
    format_hex_file(input_file, output_file)

if __name__ == "__main__":
    main()
