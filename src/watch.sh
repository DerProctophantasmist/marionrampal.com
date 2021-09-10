pushd "$(dirname "$(realpath "$0")")";  
watchify --verbose --debug index.js -o ../assets/js/bundle.js  -p [ parcelify -wo ../assets/css/bundle.css ]
popd