WWW::DeviantArt::Download
==========================

This module library's aim is to become a versatile to to download and keep art posted
to the deviantART.com website. This is to bring some peace of mind stability into the
somewhat volatile notion of having your favourites in the cloud at dA's site.

The module ships with the _dA-dl_ binary, a frontent/interface to the module's methods.
The script is similar in spirit to the very useful [youtube-dl](https://github.com/rg3/youtube-dl)
(Ruby) and [youtube-download](https://github.com/xaicron/p5-www-youtube-download) (Perl).

## dA-dl

  -d, --debug            print debug output, repeat up to 2x
  -f, --force-download   overwrite/re-download, even when file exists
  -h, --help             print this help text and exit
  -s, --scrape           also scrape HTML (provides 'description' metadata)
  -v, --version          print program version and exit
  -x, --xattr		 write image metadata to extended attributes

## Installation

With Makefile.PL:
* wget https://github.com/isync/www-deviantart-download/archive/master.tar.gz
* tar xvf master.tar.gz
* cd www-deviantart-download-master
* perl Makefile.PL
* make
* sudo make install

Or without installation:

* wget https://github.com/isync/www-deviantart-download/archive/master.zip
* unzip master.zip
* cd www-deviantart-download-master
* perl dailymotion-download some-video-url
