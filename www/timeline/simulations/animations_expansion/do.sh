g++ expansion.C -O3 -o expansion -lm

chmod +x expansion
chmod +x video_vitesse.sh

./expansion
./video_vitesse.sh acc 2 60
#./video_vitesse.sh dec 5 15
./video_vitesse.sh dec 40 30

rm -f *.res
rm -f tmp
rm -f files/*
