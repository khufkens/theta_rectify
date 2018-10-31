<a href="https://www.buymeacoffee.com/H2wlgqCLO" target="_blank"><img src="https://www.buymeacoffee.com/assets/img/custom_images/orange_img.png" alt="Buy Me A Coffee" height="21px" ></a>
<a href="https://liberapay.com/khufkens/donate"><img alt="Donate using Liberapay" src="https://liberapay.com/assets/widgets/donate.svg" height="21px"></a>

# theta_rectify

This is a small bash script which rectifies (levels the horizon) in Theta S spherical images using the internal pitch and roll values stored in the EXIF data. This is an alternative implementation to the [THETA EXIF Library](https://github.com/regen100/thetaexif) by [Regen](https://github.com/regen100). I use his cute Lama test images for reference. All credit for the funky images go to Regen.

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

![](https://i1.wp.com/www.khufkens.com/wp-content/uploads/2017/05/equirectangular.jpg?zoom=2&w=525)

![](https://i1.wp.com/www.khufkens.com/wp-content/uploads/2017/05/equirectangular_rectified.jpg?zoom=2&w=525)

Visual comparison between my results and those of [Regen's python script](http://www.regentechlog.com/2014/06/26/python-thetaexif/) show good correspondence.


## Requirements

The script depends on a running copy of exiftools, imagemagick and POVRay. These tools are commonly available in most Linux distros, and can be installed on OSX using tools such as homebrew. I lack a MS Windows system, but the script should be easily adjusted to cover similar functionality.
