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

  # create the theta_rectifier tmp dir
  TMP_DIR="/tmp/theta_rectifier"
  if [ ! -d /tmp/theta_rectifier ]; then
    echo "Making temporary directory for rectifier working files at: $TMP_DIR"
    mkdir -v $TMP_DIR
  fi

  # get the filename without the extension
  BASENAME=`basename $1`
  noextension=`echo "$1" | sed 's/\(.*\)\..*/\1/'`

  # generate a temp name so that parallel runs don't clobber each other
  TMP_ROOT="$TMP_DIR/${BASENAME}_${RANDOM}_theta_rectify.tmp"

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
  echo "Preparing image for transforms..."
  convert -define png:compression-level=1 -flop "$1" $TMP_ROOT.png

  # create povray script with correct image parameters
  cat <<EOF > $TMP_ROOT.pov
#version 3.7;
// Equirectangular Panorama Render
// bare bones script

global_settings { assumed_gamma 2.2 }

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
        png "$TMP_ROOT.png"
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

  # execute povray script and rename file
  TMP_DEST=${TMP_ROOT}_povray-out.png
  echo "Invoking POV-Ray to apply transformations..."
  povray \
    +wt1 `# use 1 thread; many threads thrashes on small files` \
    +V `# give descriptive output` \
    +W$width +H$height `# define image dimensions` \
    -D  `# don't display in-progress render` \
    +fN `#write out to PNG` \
    $TMP_ROOT.pov `# use TMP_ROOT.pov as input` \
    +O"$TMP_DEST" `# write to temp destination`

  # perform final JPEG conversion at quality 90.
  convert -quality 90 $TMP_DEST $destfile

  # remove temporary files / clean up
  echo "Cleaning up temporary files..."
  rm -v $TMP_DEST
  rm -v $TMP_ROOT.png
  rm -v $TMP_ROOT.pov

  # copy original metadata to dest, removing the corrections that have just been made
  echo "Pasting original tags..."
  exiftool -overwrite_original -a -m -TagsFromFile "$1" -all:all \
    -PosePitchDegrees=0 -PoseRollDegrees=0 \
    -ProcessingSoftware="theta_rectify.sh: git version" \
    "$destfile"
  shift
done
