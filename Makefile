COLLECTION_OPT = -collection:deps=./deps/
OUT_OPT = -out:out/game

ODIN_ROOT = $(shell odin root)
EXTRA_LINKER_FLAGS = -extra-linker-flags:"-Wl,-rpath ${ODIN_ROOT}vendor/raylib/macos"

.PHONY: default run build_debug build_production test

default: run

run:
	odin run src/main_desktop ${COLLECTION_OPT}

hot:
	odin build src/main_desktop -define:RAYLIB_SHARED=true -build-mode:dll ${OUT_OPT}.dylib -strict-style -debug ${COLLECTION_OPT} ${EXTRA_LINKER_FLAGS}
	odin build src/main_hot_reload -debug ${OUT_OPT} ${COLLECTION_OPT}

# hot_build:
# if pgrep -f $EXE > /dev/null; then
#     echo "Hot reloading..."
#     exit 0
# fi

# echo "Building $EXE"

# if [ $# -ge 1 ] && [ $1 == "run" ]; then
#     echo "Running $EXE"
#     ./$EXE &
# fi

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
