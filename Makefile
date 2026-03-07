ODIN_ROOT = $(shell odin root)

COLLECTION_OPT = -collection:deps=./deps/
OUT_OPT = -out:out/game

HOT_OPTS = -define:RAYLIB_SHARED=true -build-mode:dll -extra-linker-flags:"-Wl,-rpath ${ODIN_ROOT}vendor/raylib/macos"
HOT_TMP_OUT_OPT = -out:out/game_tmp.dylib
HOT_TMP_OUT_PATH = $(subst -out:,,$(HOT_TMP_OUT_OPT))
HOT_OUT_PATH = out/game.dylib


.PHONY: default run hot build_debug build_production test
default: run

run:
	odin run src/main_desktop ${COLLECTION_OPT}

hot_exec:
	mkdir -p out
	odin build src/main_hot_reload -debug -out:game ${COLLECTION_OPT}

hot:
	mkdir -p out
	odin build src/game -debug ${HOT_TMP_OUT_OPT} ${COLLECTION_OPT} ${HOT_OPTS}
	mv ${HOT_TMP_OUT_PATH} ${HOT_OUT_PATH}

b: build_vet
check: build_vet
build: build_vet
build_vet:
	mkdir -p out
	odin build src/main_desktop -debug -vet ${OUT_OPT} ${COLLECTION_OPT}

dbg: build_debug
debug: build_debug
build_debug:
	mkdir -p out
	odin build src/main_desktop -debug ${OUT_OPT} ${COLLECTION_OPT}

prod: build_production
build_production:
	mkdir -p out
	odin build src/main_desktop -o:speed ${OUT_OPT} ${COLLECTION_OPT}

t: test
test:
	odin test src/main_desktop
