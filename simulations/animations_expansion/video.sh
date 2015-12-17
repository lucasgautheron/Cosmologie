rm out.mp4
ffmpeg -framerate 15 -i files/%04d.png -c:v libx264 -profile:v high -crf 20 -pix_fmt yuv420p out.mp4
