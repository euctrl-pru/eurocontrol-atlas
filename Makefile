# requires Bash
SHELL := $(shell echo $$SHELL)
TOPOJSON = node_modules/.bin/topojson
TOPOMERGE = node_modules/.bin/topojson-merge
# http://www.naturalearthdata.com/downloads/
NATURAL_EARTH_CDN = http://naciscdn.org/naturalearth
GISCO_CDN = http://ec.europa.eu/eurostat/cache/GISCO/geodatafiles


# Countries of interest
#
# Eurocontrol Member States (in parenthesis ICAO and ISO 2 letter code):
#   Albania (LA,AL), Armenia (UD,AM), Austria (LO,AT),
#   Belgium (LB,BE), Bosnia and Herzegovina (LQ,BA), Bulgaria (LB,BG),
#   Croatia (LD,HR), Cyprus (LC,CY), Czech Republic (LK,CZ),
#   Denmark (EK,DK), Estonia (EE,EE), Finland (EF,FI), France (LF,FR),
#   Georgia (UG,GE), Germany(ED/ET,DE), Greece (LG,GR),
#   Hungary (LH,HU), Ireland (EI,IE), Italy (LI,IT),
#   Latvia (EV,LV), Lithuania (EY,LT), Luxembourg (EL,LU),
#   Malta (LM,MT), Moldova (LU,MD), Monaco (LN,MC), Montenegro (LY,ME),
#   Netherlands (EH,NL), Norway (EN,NO), Poland (EP,PL), Portugal (LP,PT), Romania (LR,RO),
#   Serbia (LY,RS), Slovakia (LZ,SK), Slovenia (LJ,SI), Spain (LE,ES), Sweden (ES,SE), Switzerland (LS,CH),
#   The former Yugoslav Republic of Macedonia (LW,MK), Turkey (LT,TR),
#   Ukraine (UK,UA) and United Kingdom of Great Britain and Northern Ireland (EG,GB).
#
#
# European union

.PHONY: all help
all: help

help:
	@echo "Please invoke one of the following targets:"
	@echo "world-atlas    retrieve the topojson files for 50M and 110M scale."
	@echo "nmfirs         generate the topojson file with NM FIRs for Eurocontrol Member States and FABs."
	@echo "flags          download from Wikimedia all flags of the world (SVG format)"

.SECONDARY:

info_%: shp/%/firs.shp
	ogrinfo $< -sql "SELECT * FROM firs"

.PHONY: nmfirs
nmfirs: topo/FIRs_NM.json

# GIS source (in zip) can be NM or EAD
shp/euctrl/firs-unfiltered.shp: zip/FirUir_NM.zip

shp/euctrl/%.shp:
	rm -rf $(basename $@)
	mkdir -p $(basename $@)
	unzip -d $(basename $@) $<
	for file in $(basename $@)/*; do chmod 644 $$file; mv $$file $(basename $@).$${file##*.}; done
	rmdir $(basename $@)

# select all Eurocontrol FIRs (European, 'E' and 'L' [but not Israel, LL],
# plus Kosovo, 'BK', Canaries, 'GC', Morocco, 'GM' and relevant U[B|D|G|K]).
shp/euctrl/firs.shp: shp/euctrl/firs-unfiltered.shp
	rm -f $@
	ogr2ogr -f 'ESRI Shapefile' \
		-where "(SUBSTR(AV_AIRSPAC,-3) = 'FIR') AND \
						(SUBSTR(AV_ICAO_ST, 1, 1) = 'E' or SUBSTR(AV_ICAO_ST, 1, 1) = 'L' OR \
						AV_ICAO_ST in ('BK', 'GC', 'GM', 'UB', 'UD', 'UG', 'UK')) AND \
						AV_ICAO_ST not in ('LL')" \
		$@ $<


# extract shp with FIRs for every state
shp/%/firs.shp: shp/euctrl/firs.shp
	mkdir -p $(dir $@)
	rm -f $@
	ogr2ogr -f 'ESRI Shapefile' -where "AV_ICAO_ST = '`echo $* | tr a-z A-Z`'" $@ $<


shp/ead/firs.shp:
	mkdir -p $(dir $@)
	unzip -d shp zip/FirUir_EAD.zip
	touch $@

shp/nm/firs.shp:
	mkdir -p $(dir $@)
	unzip -d $(dir $@) zip/FirUir_NM.zip
	touch $@

topo/euctrl-firs-ungrouped.json: shp/euctrl/firs.shp
	mkdir -p $(dir $@)
	node_modules/.bin/topojson \
		-o $@ \
		--no-pre-quantization \
		--post-quantization=1e6 \
		--simplify=7e-7 \
		--id-property AV_AIRSPAC \
		-e data/fabfirs.rp2.csv \
		--properties id=AV_AIRSPAC,icao=AV_ICAO_ST,name=AV_NAME,minfl=MIN_FLIGHT,maxfl=MAX_FLIGHT,fab \
		-- $<


# Group polygons into multipolygons.
topo/euctrl-%.json: topo/euctrl-%-ungrouped.json
	node_modules/.bin/topojson-group \
		-o $@ \
		-- $<



# simplification (-s) is essential to remove topological issues from originale shapefile
# the value used does not compromise details at all.
# Better understanding from http://stackoverflow.com/a/18921214/963575
#
# The external properties file (argument to '-e') defines which FIRs belong to which FAB
# topo/FIRs_NM.json: geo/FIRs_NM.json
# 	mkdir -p $(dir $@)
# 	$(TOPOJSON) \
# 		--force-clockwise \
# 		-q 1e7 \
# 		-s 1e-18 \
# 		-o $@ \
# 		--id-property AV_AIRSPAC \
# 		-e data/fabfirs.rp2.csv \
# 		--properties id=AV_AIRSPAC,icao=AV_ICAO_ST,name=AV_NAME,minfl=MIN_FLIGHT,maxfl=MAX_FLIGHT,fab \
# 		-- $<




################# WORLD ATLAS #################

# possible scales are 50m and 110m
# It is also possible to have 10m but it should be built from Mike Bostock's World Atlas
# repository https://github.com/mbostock/world-atlas
topo/world-%.json:
	mkdir -p $(dir $@)
	curl -L https://gist.github.com/mbostock/4090846/raw/$(notdir $@) -o $@

.PHONY: world-atlas
world-atlas: topo/world-50m.json topo/world-110m.json


########## FLAGS ##########

data/world-country-names.tsv:
	mkdir -p $(dir $@)
	curl -L https://gist.github.com/mbostock/4090846/raw/$(notdir $@) -o $@

flags_ids: data/world-country-names.tsv
	cat $< <(echo "900	Kosovo") | cut -f1 -s | tail -n+5 > $@

flags_names: data/world-country-names.tsv
	cat $< <(echo "900	Kosovo") | cut -f2 -s | tail -n+5 | cut -d',' -f1 | sed -e 's/[ ][ ]*/_/g' > $@

flags_urls: flags_names
	rm -f $@
	for c in $$(cat $<); \
	do \
		h=$$(md5 -qs "Flag_of_$$c.svg" | cut -c1-2); \
		f=$$(echo $$h | cut -c1); \
		u="http://upload.wikimedia.org/wikipedia/commons/$$f/$$h/Flag_of_$$c.svg"; \
		echo "$$u"; \
	done > $@

.PHONY: flags_curls
flags_curls: flags_urls
	for u in $$(cat $<); \
	do \
		echo -n $$u; curl -s -I "$$u" | grep -e '^HTTP'; \
	done | grep "404 Not Found"


data/world-country-flags.tsv: flags_ids flags_urls
	mkdir -p $(dir $@)
	paste -d '|' $^ | sed -e 's/|/	/g' > $@

.PHONY: flags
flags: flags_urls
	mkdir -p $@
	cd $@ && { xargs -n 1 curl -L -O < ../$< ; cd -; }





################## helpers ######################
.PHONY: clean-tmp clean
clean-tmp:
	rm -fR flags_ids flags_names flags_urls geo shp

clean: clean-tmp
	rm -fR flags/ topo/ geo/ shp/ data/world-country-flags.tsv data/world-country-names.tsv
