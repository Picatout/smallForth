#! /bin/bash 

# bare hexdump to text file 

EXPECTED_ARGS=2

if [ $# -ne $EXPECTED_ARGS ]; then
    echo "Error: Invalid number of arguments."
    echo "Usage: $(basename "$0") <bin_file> <text_file>"
    exit 1
fi

hexdump -v -e '16/1 " %02X" "\r"' $1 > $2 

