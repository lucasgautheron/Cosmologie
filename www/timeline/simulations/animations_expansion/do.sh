g++ expansion.C -O3 -o expansion -lm

chmod +x expansion
chmod +x video_vitesse.sh

./expansion
./video_vitesse.sh acc 5 75
#./video_vitesse.sh dec 25 15
./video_vitesse.sh dec 25 30

rm *.res
rm -rf files/*
