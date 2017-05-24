#!/bin/bash
#
# Automatically levels Theta S spherical images
# depends on exiftools / imagemagick and POVRay
# Should work on most Linux installs and on
# OSX using homebrew installs or similar

# get the filename without the extension
noextension=`echo $1 | sed 's/\(.*\)\..*/\1/'`

# grab the width and height of the images
height=`exiftool $1 | grep "^Image Height" | cut -d':' -f2 | sed 's/ //g'`
width=`exiftool $1 | grep "^Image Width" | cut -d':' -f2 | sed 's/ //g'`

# grab pitch roll
roll=`exiftool $1 | grep "Roll" | cut -d':' -f2 | sed 's/ //g'`
pitch=`exiftool $1 | grep "Pitch" | cut -d':' -f2 | sed 's/ //g'`
pitch=$(bc <<< "$pitch * -1")

# flip the image horizontally
convert -flop $1 tmp.jpg

# create povray script with correct image parameters
cat <<EOF > tmp.pov
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
        jpeg "tmp.jpg"
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
povray +W$width +H$height -D +fj tmp.pov +O${noextension}_rectified.jpg

# remove temporary files / clean up
rm tmp.jpg
rm tmp.pov


