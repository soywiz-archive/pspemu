print("Hello world from Squirrel!\n");
for (local n = 0; n < 20; n++) {
	print(n);
}

//for (local n = 0; n < 60; n++) frame();

bg   <- Bitmap.fromFile("background.jpg").centerf(0, 0);
logo <- Bitmap.fromFile("logo.png").centerf(0.5, 0.5);

n <- 0;
x <- 0;
y <- 0;
while (true) {
	x = sin(n / 20.0) * 128;
	clear();
	bg.draw(0, 0);
	color(0x7FF00000); for (local m = 0; m < 480; m += 20) line(m + 0, 0, m + 0, 272);
	{
		logo.draw(x + 480 / 2, y + 272 / 2);
	}
	for (local m = 0; m < 480; m += 20) {
		colorf([1, 0, 0, (sin(n / 20.0 + m / 10.0) + 1.0) * 0.5]);
		line(m + 10, 0, m + 10, 272);
	}
	
	frame();
	n++;
}