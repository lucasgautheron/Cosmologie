gcc dl.C -o dl -lm
./dl

rm -rf files/*
php plots_vitesse.php $1

rm "out_$1.mp4"
rm "out_$1.webm"
ffmpeg -framerate 15 -i files/%06d.png -c:v libx264 -profile:v high -crf 20 -pix_fmt yuv420p "out_$1.mp4"
ffmpeg -framerate 15 -i files/%06d.png -c:v libvpx -crf 10 -b:v 1M -c:a libvorbis "out_$1.webm"
