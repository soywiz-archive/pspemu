#include <sqlite3.h>

class Controller { public:
	Controller(const char *type = NULL) {
	}
	
	~Controller() {
	}

};

#define SQTAG_Controller (SQUserPointer)0x80000014
DSQ_RELEASE_AUTO(Controller);

float normalizeAnalog(unsigned char value) {
	int deadzone = 5;
	int value2 = ((int)value) - 0x80;
	if (value2 > 0) {
		value2 -= deadzone;
		if (value2 < 0) value2 = 0;
	} else {
		value2 += deadzone;
		if (value2 > 0) value2 = 0;
	}
	return ((float)value2) / (float)(128 - deadzone);
}

DSQ_METHOD(Controller, constructor)
{
	EXTRACT_PARAM_START();
	EXTRACT_PARAM_STR(2, type, NULL);

	Controller *self = new Controller((const char *)type.data);
	sq_setinstanceup(v, 1, self);
	sq_setreleasehook(v, 1, CSQ_RELEASE(Controller));
	
	return 0;
}

DSQ_METHOD(Controller, _get)
{
	EXTRACT_PARAM_START();
	EXTRACT_PARAM_SELF(Controller);
	EXTRACT_PARAM_STR(2, s, NULL);
	char *c = (char *)s.data;

	if (strcmp(c, "Lx") == 0) RETURN_FLOAT(normalizeAnalog(pad_data.Lx));
	if (strcmp(c, "Ly") == 0) RETURN_FLOAT(normalizeAnalog(pad_data.Ly));

	if (strcmp(c, "up"      ) == 0) RETURN_INT((pad_data.Buttons & PSP_CTRL_UP      ) != 0);
	if (strcmp(c, "down"    ) == 0) RETURN_INT((pad_data.Buttons & PSP_CTRL_DOWN    ) != 0);
	if (strcmp(c, "left"    ) == 0) RETURN_INT((pad_data.Buttons & PSP_CTRL_LEFT    ) != 0);
	if (strcmp(c, "right"   ) == 0) RETURN_INT((pad_data.Buttons & PSP_CTRL_RIGHT   ) != 0);

	if (strcmp(c, "cross"   ) == 0) RETURN_INT((pad_data.Buttons & PSP_CTRL_CROSS   ) != 0);
	if (strcmp(c, "square"  ) == 0) RETURN_INT((pad_data.Buttons & PSP_CTRL_SQUARE  ) != 0);
	if (strcmp(c, "triangle") == 0) RETURN_INT((pad_data.Buttons & PSP_CTRL_TRIANGLE) != 0);
	if (strcmp(c, "circle"  ) == 0) RETURN_INT((pad_data.Buttons & PSP_CTRL_CIRCLE  ) != 0);

	if (strcmp(c, "start"   ) == 0) RETURN_INT((pad_data.Buttons & PSP_CTRL_START   ) != 0);
	if (strcmp(c, "select"  ) == 0) RETURN_INT((pad_data.Buttons & PSP_CTRL_SELECT  ) != 0);

	if (strcmp(c, "triggerL") == 0) RETURN_INT((pad_data.Buttons & PSP_CTRL_LTRIGGER) != 0);
	if (strcmp(c, "triggerR") == 0) RETURN_INT((pad_data.Buttons & PSP_CTRL_RTRIGGER) != 0);
	
	return 0;
}

DSQ_METHOD(Controller, update)
{
	EXTRACT_PARAM_START();
	EXTRACT_PARAM_SELF(Controller);
	psp_ctrl_update();

	return 0;
}

void register_Controller(HSQUIRRELVM v) {
	CLASS_START(Controller);
	{
		NEWSLOT_METHOD(Controller, constructor, 0, "");
		NEWSLOT_METHOD(Controller, _get, 0, "");
		NEWSLOT_METHOD(Controller, update, 0, "");
	}
	CLASS_END;
}
