print("Hello world from Squirrel!\n");
printf("lang: %s\n", syslang);
printf("platform: %s\n", platform);
for (local n = 0; n < 20; n++) print(n);
print("\n");

//font <- Font("test.pgf");
font <- Font();

db <- Sqlite(":memory:");
db.query("CREATE TABLE records (name, points);");
db.query("INSERT INTO records (name, points) VALUES (?, ?);", ["soywiz", 999]);
db.query("INSERT INTO records (name, points) VALUES (?, ?);", ["nobody", 1000]);

printf("Sqlite %s\n", db.version);

foreach (n, row in db.query("SELECT * FROM records ORDER BY points DESC;")) {
	printf("Register(%d): %s, %d\n", n, row.name, row.points);
}

//sleep(500);
//for (local n = 0; n < 10; n++) frame();

printf("Before Bitmap.fromFile...\n");

bg      <- Bitmap.fromFile("background.jpg");
logo    <- Bitmap.fromFile("logo.png");
tileset <- Bitmap.fromFile("tileset.png");

printf("After Bitmap.fromFile...\n");

logo.centerf(0.5, 0.5);
tilemap <- TileMap(20, 12, 1);
for (local y = 0; y < tilemap.h; y++) {
	for (local x = 0; x < tilemap.w; x++) {
		//tilemap.set(x, y, (x + y) % 3);
		tilemap.set(x, y, rand() % 20);
	}
}

tilemap_update <- function() {
	for (local z = 0; z < 20; z++) tilemap.setTranslateBlock(z, rand() % 3);
}

tilemap_update();

ctrl.update();
if (ctrl.cross) {
	printf("Starting with cross pressed...\n");
}

sleep(100);

while (resources_loading_count() > 0) {
	printf("Loading Left(%d/3)...", 3 - resources_loading_count());
	sleep(10);
}

m <- 0;
n <- 0;
x <- 0;
y <- 0;
local madd;
while (true) {
	x = sin(n / 20.0) * 128;
	clear();
	bg.draw(0, 0);
	color(0x7FF00000); for (local j = 0; j < 480; j += 20) {
		madd = cos((m + j) / 10.0) * 20.0;
		line(j + 0 + madd, 0, j + 0 + madd, 272);
	}
	color(0x00FFFFFF);
	tilemap.draw(tileset, 24, 24, 0, 0);
	//function draw(bitmap, tile_w = 32, tile_h = 32, repeat_x = 1, repeat_y = 1, put_x = 0, put_y = 0, scroll_x = 0, scroll_y = 0, scroll_w = 16, scroll_h = 16, alpha = 1.0, margin_x = 0, margin_y = 0);
	{
		logo.draw(x + 480 / 2, y + 272 / 2);
	}
	//for (local m = 0; m < 480; m += 20) { colorf([1, 0, 0, (sin(n / 20.0 + m / 10.0) + 1.0) * 0.5]); line(m + 10, 0, m + 10, 272); }

	font.size = 0.7;
	font.color = getcolorf([0, 0.5, 0]);
	font.shadowColor = getcolorf([1, 1, 1, 1]);
	font.cut(0, m % 60).print(96, 128, "Hello! This is a test of\nintraFont\ncool!");

	font.size = 0.8;
	font.color = getcolorf([1, 1, 1, 1]);
	font.shadowColor = getcolorf([0, 0, 0, 0.5 + 0.5 * cos(PI * (((m % 60) / 60.0) - 0.5))]);
	font.print(8, 16, format("Press X to move the PSP image (%08X)", -1));
	font.print(8, 32, "Press O to change the tiles");

	/*if ((m % 20) == 0) {
		tilemap_update();
	}*/
	
	if (ctrl.circle) {
		tilemap_update();
	}
	
	frame();
	if (ctrl.cross) n++;
	m++;
}