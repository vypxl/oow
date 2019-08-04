run:
	haxe hl.hxml -hl out/oow.hl
	hl out/oow.hl

build:
	haxe hl.hxml -hl out/hlc/oow.c
	gcc -O3 -o out/oow -std=c11 -I out/hlc out/hlc/oow.c /usr/lib/sdl.hdll /usr/lib/ui.hdll /usr/lib/fmt.hdll /usr/lib/openal.hdll /usr/lib/uv.hdll -lhl -lSDL2 -lm -lopenal -lGL

js:
	haxe build.hxml -js out/js/oow.js

upload_js:
	butler push out/js vypxl/oow:web

