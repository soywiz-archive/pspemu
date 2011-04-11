module pspemu.gui.Registers;

public import pspemu.All;

class RegisterViewer : ListView {
	Registers registers;

	this(Registers registers = null) {
		super();
		
		this.registers = registers;

		dock = DockStyle.FILL;
		view = View.DETAILS;
		gridLines = true;
		fullRowSelect = true;
		allowColumnReorder = false;
		
		handleCreated ~= (Control c, EventArgs ea) { updateRegisters(); };
		doubleClick ~= (Control c, EventArgs ea) {
			writefln("blick!");
		};
	}

	void updateRegisters() {
		beginUpdate();
		{
			if (!items.length) {
				ColumnHeader createColumnHeader(string text, int width) {
					auto col = new ColumnHeader;
					col.text = text;
					col.width = width;
					return col;
				}
				
				columns.add(createColumnHeader("Sym", 32));
				//columns.add(createColumnHeader("Reg", 32));
				columns.add(createColumnHeader("Value", 64));
				for (int n = 0; n < 32; n++) {
					string name2 = std.string.format("r%d", n);
					string name1 = std.string.format("%s", Registers.aliasesInv[n]);
					auto lvi = new ListViewItem(name1);
					if (columns.length > 2) lvi.subItems.add(new ListViewSubItem(name2));
					lvi.subItems.add(new ListViewSubItem("-"));
					items.add(lvi);
				}
			}

			foreach (n, item; items) item.subItems[item.subItems.length - 1].text = std.string.format("%08X", registers ? registers.R[n] : 0);
		}
		endUpdate();
	}
}

class RegisterViewerForm : Form {
	RegisterViewer registerViewer;
	
	this(Registers registers = null) {
		//modal = true;
		text = "Registers";
		showInTaskbar = false;
		minimumSize = Size(138, 120);
		maximumSize = Size(minimumSize.width, 1024);
		controlBox  = true;
		minimizeBox = false;
		maximizeBox = false;
		//formBorderStyle = FormBorderStyle.FIXED_SINGLE;

		with (registerViewer = new RegisterViewer(registers)) {
			parent = this;
		}
		icon = null;
	}
}