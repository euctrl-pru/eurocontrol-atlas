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


## FABs

Each FAB has been assigned a unique ID, see `data/fab-id-name.csv`. This is the file that can
be used for example in `D3` to associate the id to the name.


## Getting all relevant flight levels (FLs) for a set of FIRs

Given all the FIRs for Eurocontrol as from `euctrl` target, the following jq
filter will return the list of unique FLs, i.e. the slices to consider when
merging the relevant set of FIRs:

```bash
$ jq "[.objects.firs.geometries| .[].properties | .minfl , .maxfl] | unique" firs.json
[
  0,
  195,
  245,
  275,
  285,
  999
]
```

Select all the FIRs whose `minfl` is equal to 285:

```bash
$ jq ".objects.firs.geometries| .[].properties | select(.minfl|  . == 285)" firs.json
{
  "id": "EFINUIR",
  "icao": "EF",
  "name": "FINLAND UIR",
  "minfl": 285,
  "maxfl": 999
}
{
  "id": "LYBAUIR",
  "icao": "LY",
  "name": "BEOGRAD UIR",
  "minfl": 285,
  "maxfl": 999
}
```

The FIRs that exist at FL245 are (these are the ones to be merged when
considering State or Fab aggregation):

```bash
$ jq ".objects.firs.geometries| .[].properties | select(. | .minfl <= 245 and .maxfl > 245) | .id" firs.json
"LJLAFIR"
"EISNUIR"
"LFFFUIR"
"LZBBFIR"
"LHCCFIR"
"LTBBFIR"
"EETTFIR"
"ENORFIR"
"EPWWFIR"
"LPPOFIR"
"UDDDFIR"
"EHAAFIR"
"EKDKFIR"
"LIRRUIR"
"UKLVFIR"
"LOVVFIR"
"EDVVUIR"
"LUUUFIR"
"LDZOFIR"
"LIMMUIR"
"LAAAFIR"
"UKFVFIR"
"EBURUIR"
"EFINFIR"
"LYBAFIR"
"ESAAFIR"
"EGGXFIR"
"ENOBFIR"
"EGPXUIR"
"LECBUIR"
"LMMMUIR"
"LCCCUIR"
"LTAAFIR"
"LPPCFIR"
"GCCCUIR"
"LBSRFIR"
"EGTTUIR"
"LWSSFIR"
"UGGGUIR"
"LKAAFIR"
"LQSBUIR"
"LSASUIR"
"LECMUIR"
"LRBBFIR"
"UKDVFIR"
"LIBBUIR"
"EYVLUIR"
"EVRRFIR"
"UKBVFIR"
"EDUUUIR"
"LGGGUIR"
"UKOVFIR"
```
