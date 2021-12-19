@echo off

pushd org
pushd img
pushd gallery
:: Create thumbnails for gallery images
mogrify -format png -path thumbnails -thumbnail 30%% -auto-orient *.jpg
popd
popd
popd

make clean
make

