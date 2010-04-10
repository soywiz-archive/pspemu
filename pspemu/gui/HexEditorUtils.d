module pspemu.gui.HexEditorUtils;

import dfl.all, dfl.internal.winapi, dfl.internal.utf;
//import dfl.graphicsbuffer;

import std.intrinsic, std.stdio, std.string, std.stream, std.file, std.algorithm;

import pspemu.gui.Utils;
import pspemu.core.Memory;

template HexEditorUtils_Template() {
	class GotoForm : Form {
		TextBox addressInput;
		Button  gotoButton;
		
		void updateGoto() {
			addressInput.text = std.string.format("0x%08X", cursorAddress);
		}

		this() {
			text = "Go to address...";
			showInTaskbar = false;
			setClientSizeCore(256, 28);
			controlBox  = true;
			minimizeBox = false;
			maximizeBox = false;
			topMost = true;
			icon = null;
			formBorderStyle = FormBorderStyle.FIXED_SINGLE;
			with (addressInput = new TextBox) {
				left = 8;
				top = 8;
				width = 180;
				parent = this;
			}
			with (gotoButton = new Button) {
				text = "Go to";
				left = 196;
				top = 7;
				width = 64;
				parent = this;
				click ~= (Control c, EventArgs ea) { this.close(); };
			}
			activated ~= (Control c, EventArgs ea) {
				addressInput.focus();
				addressInput.select();
				opacity = 1.0;
			};
			deactivate ~= (Control c, EventArgs ea) {
				opacity = 0.9;
			};
			addShortcut(Keys.ESCAPE, (Object sender, FormShortcutEventArgs ea) { close(); });
			startPosition = FormStartPosition.CENTER_PARENT;
			acceptButton = gotoButton;
		}
	}

	class SearchForm : Form {
		this() {
			text = "Find";
			showInTaskbar = false;
			setClientSizeCore(400, 184);
			controlBox  = true;
			minimizeBox = false;
			maximizeBox = false;
			topMost = true;
			icon = null;
			formBorderStyle = FormBorderStyle.FIXED_SINGLE;

			{ // CreateRightButtonsGroup
				ContainerControl containerControl;

				with (containerControl = new ContainerControl) {
					dock = DockStyle.RIGHT;
					width = 120;
					parent = this;
					dockPadding.all = 8;
					dockPadding.top = 14;
				}

				with (findButton = new Button) {
					text = "&Find";
					dock = DockStyle.TOP;
					parent = containerControl;
				}

				with (cancelButton2 = new Button) {
					dock = DockStyle.TOP;
					dockPadding.top = 8;
					text = "&Cancel";
					parent = containerControl;
					click ~= (Control c, EventArgs ea) { this.close(); };
				}
			}
			
			{ // CreateLeftContentGroup
				with (leftContentGroup = new ContainerControl) {
					dock = DockStyle.FILL;
					parent = this;
					dockPadding.all = 8;
				}

				{ // CreateLeftSearchForGroup
					with (searchForGroup = new GroupBox) {
						dock = DockStyle.TOP;
						text = "Search for:";
						parent = leftContentGroup;
						dockPadding.all = 0;
						height = 74;
					}

					with (searchTextBox = new ComboBox) {
						dropDownStyle = ComboBoxStyle.DROP_DOWN;
						text = "";
						parent = searchForGroup;
						dock = DockStyle.TOP;
					}

					with (searchInputType = new ComboBox) {
						dropDownStyle = ComboBoxStyle.DROP_DOWN_LIST;
						dock = DockStyle.BOTTOM;
						foreach (itemText; ["Text Search", "Hexadecimal Search", "Integer Search", "Float Search"]) {
							auto label = new Label;
							label.text = itemText;
							items.add(label);
						}
						text = "";
						parent = searchForGroup;
						searchInputType.textChanged ~= (Control c, EventArgs ea) { checkConstraints(); };
					}
				}
				
				{ // CreateLeftOptionsGroup
					with (optionsGroup = new GroupBox) {
						dock = DockStyle.FILL;
						text = "Options:";
						parent = leftContentGroup;
						dockPadding.all = 0;
					}
					
					with (searchSearchType = new ComboBox) {
						dropDownStyle = ComboBoxStyle.DROP_DOWN_LIST;
						foreach (itemText; ["Normal Search", "Case Insensitive", "Relative Search", "Pattern Search"]) {
							auto label = new Label;
							label.text = itemText;
							items.add(label);
						}
						text = "";
						dock = DockStyle.TOP;
						parent = optionsGroup;
					}
					with (searchEncodingType = new ComboBox) {
						dropDownStyle = ComboBoxStyle.DROP_DOWN_LIST;
						foreach (itemText; ["8 bit (normal)", "16 bits (unicode)", "32 bits", "Variable (last bit extend)", "UTF-8", "Shift-JIS (japanese)"]) {
							auto label = new Label;
							label.text = itemText;
							items.add(label);
						}
						text = "";
						dock = DockStyle.TOP;
						parent = optionsGroup;
					}
					with (searchEndianType = new ComboBox) {
						dropDownStyle = ComboBoxStyle.DROP_DOWN_LIST;
						foreach (itemText; ["Little Endian (intel/psp)", "Big Endian (morotola)"]) {
							auto label = new Label;
							label.text = itemText;
							items.add(label);
						}
						text = "";
						dock = DockStyle.TOP;
						parent = optionsGroup;
					}
				}
			}

			handleCreated ~= (Control c, EventArgs ea) {
				searchSearchType.selectedIndex = 0;
				searchInputType.selectedIndex = 0;
				searchEncodingType.selectedIndex = 0;
				searchEndianType.selectedIndex = 0;
				checkConstraints();
			};
			
			activated  ~= (Control c, EventArgs ea) { searchTextBox.focus(); opacity = 1.0; };
			deactivate ~= (Control c, EventArgs ea) { opacity = 0.9; };
			
			startPosition = FormStartPosition.CENTER_PARENT;
			acceptButton  = findButton;
			cancelButton  = cancelButton2;
		}
		
		void checkConstraints() {
			searchSearchType.enabled   = (searchInputType.selectedIndex == 0);
			searchEncodingType.enabled = (searchInputType.selectedIndex == 0);
		}
	}
}
