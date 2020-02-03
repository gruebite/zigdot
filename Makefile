
GDNATIVE_H=godot_headers/gdnative/gdnative.h 

all: zigdot

.PHONY: zigdot
zigdot:
	-zig build

.PHONY: install
install:
	cp zig-cache/lib/libzigdot.so $(HOME)/projects/godot/zig
