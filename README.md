![image](supersonik.png)

# Supersonik Media Player

Supersonik is a [Subsonic](https://www.subsonic.org/pages/index.jsp) music streaming client for mobile Linux platforms including SailfishOS, postmarketOS, Mobian, and others.  It is also compatible with open-source Subsonic forks such as [Airsonic](https://airsonic.github.io/).  It uses the KDE Kirigami UI framework and is written in QML and C++.

## Features

* Stream your own music collection on your Linux phone
* Missing album artwork fetched from Last.fm
* Download albums so that they can be played offline

## Compiling Supersonik

* SailfishOS: TODO

* postmarketOS:
    * Install the required packages:
        * `sudo apk add cmake qt6-qtbase qt6-qtquick3d extra-cmake-modules kirigami-dev kirigami-addons qt6-qtmultimedia amber-mpris kcolorscheme-dev kiconthemes-dev ki18n-dev`
    * Run cmake
        * `cd supersonik`
        * `mkdir build`
        * `cd build`
        * `cmake ..`
    * Run make
        * `make`
    * Install
        * `sudo make install`

* Mobian: TODO