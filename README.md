# theta_rectify

This small bash script (theta_rectify.sh) rectifies (levels the horizon) in Theta S spherical images. This is an alternative implementation to the [THETA EXIF Library](https://github.com/regen100/thetaexif) by [Regen](https://github.com/regen100). I use his cute Lama test images for reference. All credit for the funky images go to Regen.

## Install

Download, fork or copy paste the script to your machine and make it executable.

```bash
 $ chmod +x theta_rectify.sh
```

## Use

```bash
 $ theta_rectify.sh image.jpg
```

The above command will rectify the image.jpg file and output a new file called image_rectified.jpg.

![](http://www.khufkens.com/wp-content/uploads/2017/05/equirectangular.jpg)

![](http://www.khufkens.com/wp-content/uploads/2017/05/equirectangular_rectified.jpg)

Visual comparison between my results and those of [Regen's python script](http://www.regentechlog.com/2014/06/26/python-thetaexif/) show good correspondence.


## Requirements

The script depends on a running copy of exiftools, imagemagick and POVRay.
