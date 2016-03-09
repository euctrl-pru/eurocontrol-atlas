# requires Bash
SHELL := $(shell echo $$SHELL)
TOPOJSON = node_modules/.bin/topojson
TOPOMERGE = node_modules/.bin/topojson-merge
# http://www.naturalearthdata.com/downloads/
NATURAL_EARTH_CDN = http://naciscdn.org/naturalearth
GISCO_CDN = http://ec.europa.eu/eurostat/cache/GISCO/geodatafiles


join-with = $(subst $(space),$1,$2)
comma := ,
space :=
space +=
make-list = $(call join-with,$(comma),$(patsubst %,'%',$1))



# Countries of interest
#
# Eurocontrol Member States (in parenthesis ICAO code, ISO 2 letter code, ISO #):
#   Albania (LA,AL,8), Armenia (UD,AM,51), Austria (LO,AT,40),
#   Belgium (EB,BE,56), Bosnia and Herzegovina (LQ,BA,70), Bulgaria (LB,BG,100),
#   Croatia (LD,HR,191), Cyprus (LC,CY,196), Czech Republic (LK,CZ,203),
#   Denmark (EK,DK,208),
#   Estonia (EE,EE,233),
#   Finland (EF,FI,246), France (LF,FR,250),
#   Georgia (UG,GE,268), Germany(ED/ET,DE,276), Greece (LG,GR,300),
#   Hungary (LH,HU,348),
#   Ireland (EI,IE,372), Italy (LI,IT,380),
#   Latvia (EV,LV,428), Lithuania (EY,LT,440), Luxembourg (EL,LU,442),
#   Malta (LM,MT,470), Moldova (LU,MD,498), Monaco (LN,MC,492), Montenegro (LY,ME,499),
#   Netherlands (EH,NL,528), Norway (EN,NO,578),
#   Poland (EP,PL,616), Portugal (LP,PT,620),
#   Romania (LR,RO,642),
#   Serbia (LY,RS,688), Slovakia (LZ,SK,703), Slovenia (LJ,SI,705),
#   Spain (LE,ES,724), Sweden (ES,SE,752), Switzerland (LS,CH,756),
#   The former Yugoslav Republic of Macedonia (LW,MK,807), Turkey (LT,TR,792),
#   Ukraine (UK,UA,804) and United Kingdom of Great Britain and Northern Ireland (EG,GB,826).
#

ectrl_ms = LA UD LO EB LQ LB LD LC LK EK EE EF LF UG ED ET LG LH EI LI EV EY \
						EL LM LU LN LY EH EN EP LP LR LY LZ LJ LE ES LS LW LT UK EG
ectrl_irs = $(call make-list,$(ectrl_ms))

#
# European union:
#   Austria (LO,AT,40),
#   Belgium (EB,BE,56), Bulgaria (LB,BG)
#   Croatia (LD,HR,191), Cyprus (LC,CY,196), Czech Republic (LK,CZ,203),
#   Denmark (EK,DK,208),
#   Estonia (EE,EE,233),
#   Finland (EF,FI,246), France (LF,FR,250),
#   Germany(ED/ET,DE,276), Greece (LG,GR,300),
#   Hungary (LH,HU,348),
#   Ireland (EI,IE,372), Italy (LI,IT,380),
#   Latvia (EV,LV,428), Lithuania (EY,LT,440), Luxembourg (EL,LU,442),
#   Malta (LM,MT,470),
#   Netherlands (EH,NL,528),
#   Poland (EP,PL,616), Portugal (LP,PT,620),
#   Romania (LR,RO,642),
#   Slovakia (LZ,SK,703), Slovenia (LJ,SI,705), Spain (LE,ES,724), Sweden (ES,SE,752),
#   United Kingdom of Great Britain and Northern Ireland (EG,GB,826).

eu_ms = LO EB LB LD LC LK EK EE EF LF ED ET LG LH EI LI EV EY \
						EL LM EH EP LP LR LZ LJ LE ES EG


# FABs:
# Legal setup:
nefab = EE EF EV EN
dkse = EK ES
baltic = EP EY
fabec = LF ED ET EB EH EL LS
fabce = LK LZ LO LH LD LJ LQ
danube = LB LR
bluemed = LC LG LI LM LA HE DT OJ
ukei = EG EI
swfab = LP LE

fabscountries = $(nefab) $(dkse) $(baltic) $(fabec) $(fabce) $(danube) $(bluemed) $(ukei) $(swfab)
fabs = $(call make-list,$(fabscountries))


# SES RP2:
# see data/fabfirs.rp2.csv
baltic_rp2 = EPWWFIR EYVLFIR EYVLUIR
bluemed_rp2 = LCCCFIR LCCCUIR LGGGFIR LGGGUIR LIBBFIR LIBBUIR LIMMFIR LIMMUIR LIRRFIR LIRRUIR LMMMFIR LMMMUIR
danube_rp2 = LBSRFIR LRBBFIR
dkse_rp2 = EKDKFIR ESAAFIR
fabec_rp2 = EBBUFIR EBURUIR EDGGFIR EDMMFIR EDUUUIR EDVVUIR EDWWFIR EHAAFIR LFBBFIR LFEEFIR LFFFFIR LFFFUIR LFMMFIR LFRRFIR LSASFIR LSASUIR
fabce_rp1 = LHCCFIR LJLAFIR LKAAFIR LOVVFIR LZBBFIR
fabce_rp2 = LDZOFIR LHCCFIR LJLAFIR LKAAFIR LOVVFIR LZBBFIR
nefab_rp2 = EETTFIR EFINFIR EFINUIR ENOBFIR ENORFIR EVRRFIR
swfab_rp2 = GCCCFIR GCCCUIR LECBFIR LECBUIR LECMFIR LECMUIR LPPCFIR
ukei_rp2 = EGPXFIR EGPXUIR EGTTFIR EGTTUIR EISNFIR EISNUIR

firs_rp2 = $(nefab_rp2) $(dkse_rp2) $(baltic_rp2) $(fabec_rp2) $(fabce_rp2) $(danube_rp2) $(bluemed_rp2) $(ukei_rp2) $(swfab_rp2)
fabs_rp2 = $(call make-list,$(firs_rp2))


.PHONY: all help
all: euctrl ses rp2 world-atlas flags

help:
	@echo "Please invoke one of the following targets (use MINFL=TRUE to consider only FIR's on FLIGHT_MIN):"
	@echo " world-atlas   retrieve the topojson files for 50M and 110M scale."
	@echo " ses           generate the topojson files for SES (composition of FIRs only):"
	@echo "               topo/ses/ses.json contains firs, states and fabs."
	@echo " rp2           generate the topojson files for SES RP2 (composition of FIRs only):"
	@echo "               topo/rp2/rp2.json contains firs, states and fabs."
	@echo " euctrl        generate the topojson files for Eurocontrol States (composition of FIRs only):"
	@echo "               topo/euctrl/euctrl.json contains firs, states and fabs."
	@echo " flags         download from Wikimedia all flags of the world (SVG format)"

.SECONDARY:

info_%: shp/%/firs.shp
	ogrinfo $< -sql "SELECT * FROM firs"

.PHONY: euctrl ses rp2
ses: topo/ses/ses.json

rp2: topo/rp2/rp2.json

euctrl: topo/euctrl/euctrl.json


# GIS source (in zip) can be NM or EAD
shp/euctrl/firs-unfiltered.shp: zip/FirUir_NM.zip

shp/euctrl/%.shp:
	rm -rf $(basename $@)
	mkdir -p $(basename $@)
	unzip -d $(basename $@) $<
	for file in $(basename $@)/*; do chmod 644 $$file; mv $$file $(basename $@).$${file##*.}; done
	rmdir $(basename $@)


####################### EUROCONTROL ###########################

# select all Eurocontrol Member States IRs (Information Regions, both FIRs and UIRs)
# NOTE: filter out the FIR w/ id
#          * EGGX (fake one to shape the REROUTING AREA)
#          * BODO a piece of volume contested btween Norway and Russia
shp/euctrl/firs.shp: shp/euctrl/firs-unfiltered.shp
	rm -f $@
	ogr2ogr -f 'ESRI Shapefile' \
		-where "AV_ICAO_ST IN ($(ectrl_irs)) AND \
						AV_AIRSPAC NOT IN ('EGGX', 'BODO') \
						$(if $(MINFL), AND MIN_FLIGHT = 0)" \
		$@ $<

topo/euctrl/firs.json: shp/euctrl/firs.shp data/firfabstates.ses.csv
	mkdir -p $(dir $@)
	node_modules/.bin/topojson \
		-o $@ \
		--id-property AV_AIRSPAC \
		-e data/firfabstates.ses.csv \
		--properties id=AV_AIRSPAC,icao=AV_ICAO_ST,name=AV_NAME,minfl=MIN_FLIGHT,maxfl=MAX_FLIGHT,fab \
		-- $<

# merge FIRs belonging to the same State
topo/euctrl/states.json: topo/euctrl/firs.json
	mkdir -p $(dir $@)
	node_modules/.bin/mapshaper $< -dissolve icao -rename-layers states -rename-fields id=icao -o $@


# merge FIRs belonging to the same FAB
topo/euctrl/fabs.json: topo/euctrl/firs.json
	mkdir -p $(dir $@)
	node_modules/.bin/mapshaper $< -dissolve fab -rename-layers fabs -rename-fields id=fab -o $@


topo/euctrl/euctrl.json: topo/euctrl/firs.json topo/euctrl/states.json topo/euctrl/fabs.json
	mkdir -p $(dir $@)
	node_modules/.bin/topojson \
		-o $@ \
		--properties id,name,fab \
		-- $^

# TODO: merge at different FL.
# ( maybe needed when converting from SHP to topojson:
#		--no-pre-quantization \
#		--post-quantization=1e5 \
#		--simplify=1e-7 \
# )
# For example
# 1. take [F|U]IR's for fab=FABEC
# 2. find all relevant FL in the FLIGHT_MIN and FLIGHT_MAX
#    Say you have slices like 0-195, 195-999
# 3. Merge separatly the slices, merge IR's at FL=0 and at FL=195
#    For one slice, you could:
#       topojson-merge --io firs --oo states --key 'd.properties.icao' -- $< > $@
#    "fabs": {"type": "GeometryCollection", "geometries":[
#       {"type": "",
#        "arcs": [],
#        "id": "fabce"},
#       {},
#       ...
#     ]}
# 4. combine 3. in 1 topojson file



##################### SES ###########################

# select all FIRs relevant for FABs' legal entities
# (Egypt, 'HE', Tunisia, 'DT' and Jordan, 'OJ' are observers in BLUMED FAB).
# NOTE: filter out the FIR w/ id
#          * EGGX (fake one to shape the REROUTING AREA)
#          * BODO a piece of volume contested btween Norway and Russia
# NOTE: we take only FIRs, i.e. IRs with MIN_FLIGHT level == 0
shp/ses/firs.shp: shp/euctrl/firs-unfiltered.shp
	rm -f $@
	mkdir -p $(basename $@)
	ogr2ogr -f 'ESRI Shapefile' \
		-where "AV_ICAO_ST IN ($(fabs)) AND \
						AV_AIRSPAC NOT IN ('EGGX', 'BODO') \
						$(if $(MINFL), AND MIN_FLIGHT = 0)" \
		$@ $<

# properties in shapefile
data/firs.tsv: shp/ses/firs.dbf
	node_modules/.bin/dbf2dsv $< | tail -n +2 > $@

# mapping FIR <--> FAB
data/firfabstates.ses.csv: data/firs.tsv
	tail -n +2 data/fabstates.ses.csv |sed 's/\([^,]*\),\([^,]*\)/s%\1%\2%/' > sed.script
	cut -d '	' -f 3 $< | sed -f sed.script > /tmp/f2
	cut -d '	' -f 2 $< > /tmp/f1
	gsed -i '1i AV_AIRSPAC' /tmp/f1
	gsed -i '1i fab' /tmp/f2
	paste -d , /tmp/f1 /tmp/f2 > $@
	rm -f -- sed.script /tmp/f1 /tmp/f2

# select all IRs relevant for SES States
# (Egypt, 'HE', Tunisia, 'DT' and Jordan, 'OJ' are observers in BLUEMED FAB).
topo/ses/firs.json: shp/ses/firs.shp data/firfabstates.ses.csv
	rm -f $@
	mkdir -p $(basename $@)
	node_modules/.bin/topojson \
		-o $@ \
		--id-property AV_AIRSPAC \
		-e data/firfabstates.ses.csv \
		--properties icao=AV_ICAO_ST,id=AV_AIRSPAC,name=AV_NAME,minfl=MIN_FLIGHT,maxfl=MAX_FLIGHT,fab \
		-- $<

# merge FIRs belonging to the same State
topo/ses/states.json: topo/ses/firs.json
	mkdir -p $(dir $@)
	node_modules/.bin/mapshaper $< -dissolve icao -rename-layers states -rename-fields id=icao -o $@


# merge FIRs belonging to the same FAB
topo/ses/fabs.json: topo/ses/firs.json
	mkdir -p $(dir $@)
	node_modules/.bin/mapshaper $< -dissolve fab -rename-layers fabs -rename-fields id=fab -o $@


topo/ses/ses.json: topo/ses/firs.json topo/ses/states.json topo/ses/fabs.json
	mkdir -p $(dir $@)
	node_modules/.bin/topojson \
		-o $@ \
		--properties id,name,fab \
		-- $^


#----------------- RP2 ------------------

# select all IRs relevant for FABs' SES RP2
# (Egypt, 'HE', Tunisia, 'DT' and Jordan, 'OJ' are observers in BLUEMED FAB).
# NOTE: we take only FIRs, i.e. IRs with MIN_FLIGHT level == 0
shp/rp2/firs.shp: shp/ses/firs.shp
	rm -f $@
	mkdir -p $(basename $@)
	ogr2ogr -f 'ESRI Shapefile' \
		-where "AV_AIRSPAC in ($(fabs_rp2)) \
						$(if $(MINFL), AND MIN_FLIGHT = 0)" \
		$@ $<

topo/rp2/firs.json: shp/rp2/firs.shp
	mkdir -p $(dir $@)
	node_modules/.bin/topojson \
		-o $@ \
		-e data/fabfirs.rp2.csv \
		--id-property AV_AIRSPAC \
		--properties id=AV_AIRSPAC,icao=AV_ICAO_ST,name=AV_NAME,minfl=MIN_FLIGHT,maxfl=MAX_FLIGHT,fab \
		-- $<

# merge FIRs belonging to the same State
topo/rp2/states.json: topo/rp2/firs.json
	mkdir -p $(dir $@)
	node_modules/.bin/mapshaper $< -dissolve icao -rename-layers states -rename-fields id=icao -o $@

# merge FIRs belonging to the same FAB
topo/rp2/fabs.json: topo/rp2/firs.json
	mkdir -p $(dir $@)
	node_modules/.bin/mapshaper $< -dissolve fab -rename-layers fabs -rename-fields id=fab -o $@


topo/rp2/rp2.json: topo/rp2/firs.json topo/rp2/states.json topo/rp2/fabs.json
	mkdir -p $(dir $@)
	node_modules/.bin/topojson \
		-o $@ \
		--properties id,name,fab \
		-- $^

################# WORLD ATLAS #################

# possible scales are 50m and 110m
# It is also possible to have 10m but it should be built from Mike Bostock's World Atlas
# repository https://github.com/mbostock/world-atlas
topo/world-%.json:
	mkdir -p $(dir $@)
	curl -L https://gist.github.com/mbostock/4090846/raw/$(notdir $@) -o $@

.PHONY: world-atlas
world-atlas: topo/world-50m.json topo/world-110m.json


#################### EUROCONTROL ATLAS #####################
# this is a subset of the world, i.e. the countries in Europe and
# the neighboring ones needed to plot decent maps

data/world-country-names.tsv:
	mkdir -p $(dir $@)
	curl -L https://gist.github.com/mbostock/4090846/raw/$(notdir $@) -o $@

data/country-ids: data/country-id-name.csv
	cut -d ',' -f1 -s $<  > $@

data/country-id-name.csv: data/world-country-names.tsv
	cat $< <(echo "900	Kosovo") | cut -f1,2 -s | tail -n+5 | cut -d',' -f1 | sed -e 's/	/,/'  > $@

data/eu.csv: data/country-id-name.csv data/eu-members.csv
	awk 'BEGIN {FS = ","; OFS = "," }; FNR==NR{a[$$1]=$$2;next} ($$1 in a) {print $$1,$$2,$$3,a[$$1]}' $? > $@


########## FLAGS ##########
data/flags-names: data/country-id-name.csv
	cut -d ',' -f2 $< | sed -e 's/[ ][ ]*/_/g' > $@

data/flags-urls: data/flags-names
	rm -f $@
	for c in $$(cat $<); \
	do \
		h=$$(md5 -qs "Flag_of_$$c.svg" | cut -c1-2); \
		f=$$(echo $$h | cut -c1); \
		u="http://upload.wikimedia.org/wikipedia/commons/$$f/$$h/Flag_of_$$c.svg"; \
		echo "$$u"; \
	done > $@

.PHONY: flags_curls
flags_curls: data/flags-urls
	for u in $$(cat $<); \
	do \
		echo -n $$u; curl -s -I "$$u" | grep -e '^HTTP'; \
	done | grep "404 Not Found"


data/world-country-flags.tsv: data/country-ids data/flags-urls
	mkdir -p $(dir $@)
	paste -d '|' $^ | sed -e 's/|/	/g' > $@

flags/Flag_of_%.svg:
	mkdir -p $(dir $@)
	( \
		h=$$(md5 -qs "$(notdir $@)" | cut -c1-2); \
		f=$$(echo $$h | cut -c1); \
		u="http://upload.wikimedia.org/wikipedia/commons/$$f/$$h/$(notdir $@)"; \
		curl -L -o "$@" $$u; \
	)


.PHONY: flags
flags: data/flags-names
	$(MAKE) $$(sed -e 's/^/flags\/Flag_of_/' -e 's/$$/.svg/' $<)




################## helpers ######################
.PHONY: clean-tmp clean
clean-tmp:
	rm -fR \
					geo shp \
					data/eu.csv \
					data/firs.tsv \
					topo/euctrl/fabs.json topo/euctrl/firs.json topo/euctrl/states.json \
					topo/rp2/fabs.json topo/rp2/firs.json topo/rp2/states.json \
					topo/ses/fabs.json topo/ses/firs.json topo/ses/states.json \
					data/flags-urls data/world-country-flags.tsv \
					data/country-id-name.csv data/country-ids data/flags-names

clean: clean-tmp
	rm -fR flags/ topo/ shp/


.PHONY: test
test:
	@echo "$(fabs)"
