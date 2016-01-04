gcc expansion.C -O3 -o expansion -lm

chmod +x expansion
chmod +x video_vitesse.sh

./expansion
./video_vitesse.sh acc
./video_vitesse.sh dec

