pragma(lib, "glut32.lib");

extern (C) {
	// GLUT initialization sub-API.
	void glutInit(int *argcp, char **argv);
	void __glutInitWithExit(int *argcp, char **argv, void function(int) exitfunc);
	//static void glutInit_ATEXIT_HACK(int *argcp, char **argv) { __glutInitWithExit(argcp, argv, exit); }
	//glutInit glutInit_ATEXIT_HACK
	void glutInitDisplayMode(uint mode);
	void glutInitDisplayString(const char *string);
	void glutInitWindowPosition(int x, int y);
	void glutInitWindowSize(int width, int height);
	void glutMainLoop();

	// GLUT window sub-API.
	int glutCreateWindow(const char *title);
	int __glutCreateWindowWithExit(const char *title, void function(int) exitfunc);
	//static int glutCreateWindow_ATEXIT_HACK(const char *title) { return __glutCreateWindowWithExit(title, exit); }
	//glutCreateWindow glutCreateWindow_ATEXIT_HACK
	int glutCreateSubWindow(int win, int x, int y, int width, int height);
	void glutDestroyWindow(int win);
	void glutPostRedisplay();
	void glutPostWindowRedisplay(int win);
	void glutSwapBuffers();
	int glutGetWindow();
	void glutSetWindow(int win);
	void glutSetWindowTitle(const char *title);
	void glutSetIconTitle(const char *title);
	void glutPositionWindow(int x, int y);
	void glutReshapeWindow(int width, int height);
	void glutPopWindow();
	void glutPushWindow();
	void glutIconifyWindow();
	void glutShowWindow();
	void glutHideWindow();
	void glutFullScreen();
	void glutSetCursor(int cursor);
	void glutWarpPointer(int x, int y);

	// GLUT overlay sub-API.
	void glutEstablishOverlay();
	void glutRemoveOverlay();
	void glutUseLayer(int layer);
	void glutPostOverlayRedisplay();
	void glutPostWindowOverlayRedisplay(int win);
	void glutShowOverlay();
	void glutHideOverlay();

	// GLUT menu sub-API.
	int glutCreateMenu(void function(int) func);
	int __glutCreateMenuWithExit(void function(int) func, void function(int) exitfunc);
	//static int glutCreateMenu_ATEXIT_HACK(void function(int) func) { return __glutCreateMenuWithExit(func, exit); }
	//glutCreateMenu glutCreateMenu_ATEXIT_HACK
	void glutDestroyMenu(int menu);
	int glutGetMenu();
	void glutSetMenu(int menu);
	void glutAddMenuEntry(const char *label, int value);
	void glutAddSubMenu(const char *label, int submenu);
	void glutChangeToMenuEntry(int item, const char *label, int value);
	void glutChangeToSubMenu(int item, const char *label, int submenu);
	void glutRemoveMenuItem(int item);
	void glutAttachMenu(int button);
	void glutDetachMenu(int button);

	// GLUT window callback sub-API.
		
	void glutReshapeFunc(void function(int width, int height) func);
	void glutKeyboardFunc(void function(ubyte key, int x, int y) func);
	void glutMouseFunc(void function(int button, int state, int x, int y) func);
	void glutMotionFunc(void function(int x, int y) func);
	void glutPassiveMotionFunc(void function(int x, int y) func);
	void glutEntryFunc(void function(int state) func);
	void glutVisibilityFunc(void function(int state) func);
	void glutIdleFunc(void function() func);
	void glutTimerFunc(uint millis, void function(int value) func, int value);
	void glutMenuStateFunc(void function(int state) func);
	void glutSpecialFunc(void function(int key, int x, int y) func);
	void glutSpaceballMotionFunc(void function(int x, int y, int z) func);
	void glutSpaceballRotateFunc(void function(int x, int y, int z) func);
	void glutSpaceballButtonFunc(void function(int button, int state) func);
	void glutButtonBoxFunc(void function(int button, int state) func);
	void glutDialsFunc(void function(int dial, int value) func);
	void glutTabletMotionFunc(void function(int x, int y) func);
	void glutTabletButtonFunc(void function(int button, int state, int x, int y) func);
	void glutMenuStatusFunc(void function(int status, int x, int y) func);
	void glutOverlayDisplayFunc(void function() func);
	void glutWindowStatusFunc(void function(int state) func);
	void glutKeyboardUpFunc(void function(ubyte key, int x, int y) func);
	void glutSpecialUpFunc(void function(int key, int x, int y) func);
	void glutJoystickFunc(void function(uint buttonMask, int x, int y, int z) func, int pollInterval);

	// GLUT color index sub-API.
	void glutSetColor(int, float red, float green, float blue);
	float glutGetColor(int ndx, int component);
	void glutCopyColormap(int win);

	// GLUT state retrieval sub-API.
	int glutGet(int type);
	int glutDeviceGet(int type);
	// GLUT extension support sub-API
	int glutExtensionSupported(const char *name);
	int glutGetModifiers();
	int glutLayerGet(int type);

	// GLUT font sub-API
	void glutBitmapCharacter(void *font, int character);
	int glutBitmapWidth(void *font, int character);
	void glutStrokeCharacter(void *font, int character);
	int glutStrokeWidth(void *font, int character);
	int glutBitmapLength(void *font, const ubyte *string);
	int glutStrokeLength(void *font, const ubyte *string);

	// GLUT pre-built models sub-API
	void glutWireSphere(double radius, int slices, int stacks);
	void glutSolidSphere(double radius, int slices, int stacks);
	void glutWireCone(double base, double height, int slices, int stacks);
	void glutSolidCone(double base, double height, int slices, int stacks);
	void glutWireCube(double size);
	void glutSolidCube(double size);
	void glutWireTorus(double innerRadius, double outerRadius, int sides, int rings);
	void glutSolidTorus(double innerRadius, double outerRadius, int sides, int rings);
	void glutWireDodecahedron();
	void glutSolidDodecahedron();
	void glutWireTeapot(double size);
	void glutSolidTeapot(double size);
	void glutWireOctahedron();
	void glutSolidOctahedron();
	void glutWireTetrahedron();
	void glutSolidTetrahedron();
	void glutWireIcosahedron();
	void glutSolidIcosahedron();

	// GLUT video resize sub-API.
	int glutVideoResizeGet(int param);
	void glutSetupVideoResizing();
	void glutStopVideoResizing();
	void glutVideoResize(int x, int y, int width, int height);
	void glutVideoPan(int x, int y, int width, int height);

	// GLUT debugging sub-API.
	void glutReportErrors();

	// GLUT device control sub-API.
	// glutSetKeyRepeat modes.
	enum {
		GLUT_KEY_REPEAT_OFF		    = 0,
		GLUT_KEY_REPEAT_ON		    = 1,
		GLUT_KEY_REPEAT_DEFAULT		= 2,
	}

	// Joystick button masks.
	enum {
		GLUT_JOYSTICK_BUTTON_A		= 1,
		GLUT_JOYSTICK_BUTTON_B		= 2,
		GLUT_JOYSTICK_BUTTON_C		= 4,
		GLUT_JOYSTICK_BUTTON_D		= 8,
	}

	void glutIgnoreKeyRepeat(int ignore);
	void glutSetKeyRepeat(int repeatMode);
	void glutForceJoystickFunc();

	//enum : GLenum {
	enum : int {
		GLUT_GAME_MODE_ACTIVE           = 0,
		GLUT_GAME_MODE_POSSIBLE         = 1,
		GLUT_GAME_MODE_WIDTH            = 2,
		GLUT_GAME_MODE_HEIGHT           = 3,
		GLUT_GAME_MODE_PIXEL_DEPTH      = 4,
		GLUT_GAME_MODE_REFRESH_RATE     = 5,
		GLUT_GAME_MODE_DISPLAY_CHANGED  = 6,
	}

	void glutGameModeString(const char *string);
	int glutEnterGameMode();
	void glutLeaveGameMode();
	int glutGameModeGet(int mode);
}

void test2() {
}

void test(int v) {
}

int main(string[] args) {
	glutCreateWindow("Hello World");
	glutWindowStatusFunc(&test);
	glutDisplayFunc(&test2);
	glutMainLoop();
	//glutInit(null, null);
	return 0;
}