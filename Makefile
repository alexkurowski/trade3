.PHONY: default run build_debug build_production test

default: run

COLLECTIONS_OPT = -collection:deps=./deps/
OUTPUT_PATH_OPT = -out:out/game

run:
	odin run src/main_desktop ${COLLECTIONS_OPT}

b: build_vet
check: build_vet
build: build_vet
build_vet:
	mkdir -p out
	odin build src/main_desktop -debug -vet ${OUTPUT_PATH_OPT} ${COLLECTIONS_OPT}

dbg: build_debug
debug: build_debug
build_debug:
	mkdir -p out
	odin build src/main_desktop -debug ${OUTPUT_PATH_OPT} ${COLLECTIONS_OPT}

prod: build_production
build_production:
	mkdir -p out
	odin build src/main_desktop -o:speed ${OUTPUT_PATH_OPT} ${COLLECTIONS_OPT}

t: test
test:
	odin test src/main_desktop
