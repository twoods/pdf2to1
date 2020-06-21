#!/bin/bash
# Split 2 page side-by-side PDF into single pages
# You must pass the number of physical pages in the side-by-side PDF
# pdf2to1.sh example.pdf 10
# TODO: Determine number of pages automatically
# TODO: Allow user provided output file name

if [ $# -ne 2 ]; then
    echo "$(basename "$0") PDF_FILE PAGE_COUNT" >&2
    exit 1
fi

INFILE="$1"
PAGE_COUNT="$2"

# Create output file name
OUTFILE="$(basename ${INFILE} .pdf)-single.pdf"

TEMP_DIR=$(mktemp -d)
if [ $? -ne 0 ]; then
    echo "Error creating temporary directory" >&2
    exit 1
fi
trap "rm -rf ${TEMP_DIR}" EXIT

ODD_PAGES=${TEMP_DIR}/odd-pages.pdf
EVEN_PAGES=${TEMP_DIR}/even-pages.pdf

# Split pages into evens and odds
pdfjam -o "${ODD_PAGES}" --trim '0in 0in 5.5in 0in' --scale 1.141 "${INFILE}"
pdfjam -o "${EVEN_PAGES}" --trim '5.5in 0in 0in 0in' --scale 1.141 "${INFILE}"

for page_no in $(seq 1 ${PAGE_COUNT}); do
    PAGE_LIST+=("${ODD_PAGES}" ${page_no});
    PAGE_LIST+=("${EVEN_PAGES}" ${page_no});
done
pdfjam --fitpaper true --rotateoversize true --suffix joined \
       ${PAGE_LIST[@]} --outfile "${OUTFILE}"
