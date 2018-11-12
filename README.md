<a href="https://www.buymeacoffee.com/H2wlgqCLO" target="_blank"><img src="https://www.buymeacoffee.com/assets/img/custom_images/orange_img.png" alt="Buy Me A Coffee" height="21px" ></a>
<a href="https://liberapay.com/khufkens/donate"><img alt="Donate using Liberapay" src="https://liberapay.com/assets/widgets/donate.svg" height="21px"></a>

# theta_rectify

This is a small bash script which rectifies (levels the horizon) in Ricoh Theta (both Theta S and Theta V) spherical images using the internal pitch and roll values stored in the EXIF data. This is an alternative implementation to the [THETA EXIF Library](https://github.com/regen100/thetaexif) by [Regen](https://github.com/regen100). I use his cute Lama test images for reference. All credit for the funky images go to Regen.

## Install

Download, fork or copy paste the script to your machine and make it executable.

```bash
 $ chmod +x theta_rectify.sh
```

## Use

```bash
 $ theta_rectify.sh image.jpg
```

The above command will rectify the `image.jpg` file and output a new file called `image_rectified.jpg`. After the first run, the script won't overwrite already rectified files, unless you use the `-f` option: `theta_rectify -f image.jpg`.

You can also bulk rectify several images at the same time passing them on the command line. For example:

```bash
 $ theta_rectify.sh *.jpg
```

![](https://www.khufkens.com/uploads/2017/05/equirectangular.jpg?zoom=2&w=525)
![](https://www.khufkens.com/uploads/2017/05/equirectangular_rectified.jpg?zoom=2&w=525)

Visual comparison between my results and those of [Regen's python script](http://www.regentechlog.com/2014/06/26/python-thetaexif/) show good correspondence.


## Requirements

The script depends on a running copy of exiftools, imagemagick and POVRay. These tools are commonly available in most Linux distros, and can be installed on MacOS using tools such as homebrew.

**On Debian and Ubuntu** Linux you can install the required packages this way:

```bash
 $ sudo apt update
 $ sudo apt install imagemagick libimage-exiftool-perl povray
```

**On MacOS** first install [homebrew](https://brew.sh/) and then install the requirements like this:

```bash
 $ brew upgrade
 $ brew install exiftool imagemagick povray
```

**On Windows 10** you can finally get a regular Linux bash environment. Just enable the [*Windows Subsystem for Linux*](https://docs.microsoft.com/en-us/windows/wsl/install-win10) (WSL) and then [install Ubuntu App](https://tutorials.ubuntu.com/tutorial/tutorial-ubuntu-on-windows#0) from the Windows Store. Once ready, start Ubuntu app from the Windows menu and install the required packages using the above commands, as in a regular Ubuntu system. Remember that usual Windows users home directories can be acessed from the Ubuntu App at the `/mnt/c/User` path.
