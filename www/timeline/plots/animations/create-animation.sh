#!/bin/sh

# path to gnuplot-combine-svg.py and svg-animate-layers.py
PATH_TO_SCRIPTS=.

# delete possible old images
# rm -f example-0*.svg

# generate source images
# ./generate-svgs.m

# combine individual graphs into a single svg file,
# extract background into a separate group (Inkscape layer)
$PATH_TO_SCRIPTS/gnuplot-combine-svg.py --out combined.svg files/*.svg

# create an animated svg out of the combined svg
# keep the background layer ("common_bg") as static - always visible
# let the animation repeat itself
$PATH_TO_SCRIPTS/svg-animate-layers.py --out animated.svg --static common_bg \
	--end repeat --fps 5 combined.svg

echo
echo "If all went well there should be a file called 'example-animated.svg'"
echo "in the current directory. Once opened in a viewer (e.g. recent"
echo "web browser) you should see an animation."
