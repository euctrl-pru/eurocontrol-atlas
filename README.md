# Eurocontrol Atlas TopoJSON

This repository provides a convenient mechanism for generating TopoJSON files for Eurocontrol region

## Installing via Homebrew (OS X)

Before you can make any TopoJSON files, you’ll need to install Node.js and GDAL. Here’s how to do that using [Homebrew](http://mxcl.github.com/homebrew/) on Mac OS X:

```bash
brew install node gdal
```

Then, clone this repository and install its dependencies:

```bash
git clone https://github.com/euctrl-pru/eurocontrol-atlas.git
cd eurocontrol-atlas
npm install
```

## Make Targets

Once you have everything installed, you can make various targets defined in the Makefile.


```bash
make help
```
