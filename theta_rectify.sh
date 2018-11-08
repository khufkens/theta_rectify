#!/bin/bash
#
# Automatically levels Ricoh Theta spherical images
# depends on exiftools / imagemagick and POVRay
# Should work on most Linux installs and on
# OSX using homebrew installs or similar

# Print usage
HELP="Usage: theta_rectify.sh [-f] FILE [FILE ...]
  Automatically levels Ricoh Theta spherical images"
if [ "${#}" == 0 ] || [ "$1" = "--help" ] ; then
    echo "$HELP"
    exit 1;
fi

# check if the user requested us to overwrite previously processed images
FORCE=0
if [ "$1" = "-f" ]; then
  FORCE=1
  echo "-f passed; will clobber extant files."
  shift
fi

# Process each file passed on the command line
while [ ${#} -gt 0 ]
do
  if [ ! -e "$1" ]; then
    echo "File $1 not found."
    exit 2
  fi

  # get the filename without the extension
  noextension=`echo "$1" | sed 's/\(.*\)\..*/\1/'`

  # generate a temp name so that parallel runs don't clobber each other
  TMP_ROOT="${RANDOM}_theta_rectify.tmp"

  # calculate destination name and check for existence before proceeding
  destfile="${noextension}_rectified.jpg"

  if [ -e "$destfile" -a $FORCE -ne 1 ]; then
    echo "Converted file ${destfile} already exists. Skipping. Use -f to force."
    shift
    continue
  fi

  # extract metadata from image
  EXIF=$(exiftool "$1")

  # grab the width and height of the images from previously extracted metadata
  height=`echo "$EXIF" | grep "^Image Height" | cut -d':' -f2 | sed 's/ //g' | head -n1`
  width=`echo "$EXIF" | grep "^Image Width" | cut -d':' -f2 | sed 's/ //g' | head -n1`

  # grab pitch roll
  roll=`echo "$EXIF" | grep "Roll" | cut -d':' -f2 | sed 's/ //g' | head -n1`
  pitch=`echo "$EXIF" | grep "Pitch" | cut -d':' -f2 | sed 's/ //g' | head -n1`
  pitch=$(bc <<< "$pitch * -1")

  # flip the image horizontally
  convert -flop "$1" $TMP_ROOT.jpg

  # create povray script with correct image parameters
  cat <<EOF > $TMP_ROOT.pov
// Equirectangular Panorama Render
// bare bones script

// camera settings
camera {
  spherical // equirectangular projection
  up    y * 1
  right  x * image_width / image_height
  location <0,0,0>     // put camera at origin
  angle 360 180        // full image
  rotate x * 0         // Tilt up (+) or down (-)
  rotate y * -90         // Look left (+) or right (-)
  rotate z * 0         // Rotate CCW (+) or CW (-)
}

// create a sphere shape
sphere {
  // center of sphere
  <0,0,0>, 1
  texture {
    pigment {
      image_map {
        jpeg "$TMP_ROOT.jpg"
        interpolate 2 // smooth it
        once   // don't tile image, just one copy
        map_type 1
      }
    }
    rotate x * $roll   //Tilt up (+) or down (-) or PITCH
    rotate y * 0       //shift left (+) or right (-)
    rotate z * $pitch  //Rotate CCW (+) or CW (-) or ROLL
    finish { ambient 1 }
  }
}
EOF

  # execute povray script, save output to temporary file and rename it
  TMP_DEST=${TMP_ROOT}_rectified.jpg
  povray +W$width +H$height -D +fj $TMP_ROOT.pov "+O$TMP_DEST"
  mv "$TMP_DEST" "$destfile"

  # remove temporary files / clean up
  rm $TMP_ROOT.jpg
  rm $TMP_ROOT.pov

  # copy original metadata to dest, removing the corrections that have just been made
  exiftool -overwrite_original -TagsFromFile "$1" -PosePitchDegrees= -PoseRollDegrees= "$destfile"
  shift
done
