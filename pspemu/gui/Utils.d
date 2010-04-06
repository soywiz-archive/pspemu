module pspemu.gui.Utils;

private import dfl.all;

template MenuAdder() {
	Menu currentMenu = null;

	MenuItem addMenu(string name, void delegate(MenuItem, EventArgs) registerCallback, void delegate() menuGenerateCallback = null) {
		if (currentMenu is null) currentMenu = menu;
		Menu backMenu = currentMenu;

		MenuItem menuItem = new MenuItem;
		menuItem.text = name;
		menuItem.parent = backMenu;
		if (registerCallback !is null) menuItem.click ~= registerCallback;

		currentMenu = menuItem;
		{
			if (menuGenerateCallback !is null) menuGenerateCallback();
		}
		currentMenu = backMenu;
		
		return menuItem;
	}

	MenuItem addMenu(string name, void delegate() menuGenerateCallback = null) {
		return addMenu(name, null, menuGenerateCallback);
	}
}
