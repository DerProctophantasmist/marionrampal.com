pushd "$(dirname "$(realpath "$0")")";
watchify --debug index.js -o ../assets/js/bundle.js  -p [ parcelify -wo ../assets/css/bundle.css ]
popd