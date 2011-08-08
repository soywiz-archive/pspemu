LIBTARGET = ..\wxd.lib

MAKESTUB=..\config.mak

OBJECTS = \
	Accelerator.obj \
	ActivateEvent.obj \
	App.obj \
	ArtProvider.obj \
	Bitmap.obj \
	BitmapButton.obj \
	BoxSizer.obj \
	Brush.obj \
	Button.obj \
	CalendarCtrl.obj \
	Caret.obj \
	CheckBox.obj \
	ChildFocusEvent.obj \
	Choice.obj \
	ChoiceDialog.obj \
	ClientData.obj \
	Clipboard.obj \
	CloseEvent.obj \
	Colour.obj \
	ColourDialog.obj \
	ComboBox.obj \
	CommandEvent.obj \
	Config.obj \
	ContextMenuEvent.obj \
	Control.obj \
	Cursor.obj \
	DC.obj \
	DND.obj \
	DataFormat.obj \
	DataObject.obj \
	Defs.obj \
	Dialog.obj \
	DirDialog.obj \
	Display.obj \
	DisplayChangedEvent.obj \
	DocManager.obj \
	DocTemplate.obj \
	Document.obj \
	EraseEvent.obj \
	Event.obj \
	EvtHandler.obj \
	FileDialog.obj \
	FindReplaceDialog.obj \
	FlexGridSizer.obj \
	FocusEvent.obj \
	Font.obj \
	FontDialog.obj \
	FontMisc.obj \
	Frame.obj \
	GDIObject.obj \
	GLCanvas.obj \
	Gauge.obj \
	GdiCommon.obj \
	GridBagSizer.obj \
	GridSizer.obj \
	HelpEvent.obj \
	HTML.obj \
	HtmlHelpController.obj \
	HtmlListBox.obj \
	IControlWithItems.obj \
	Icon.obj \
	IconizeEvent.obj \
	IdleEvent.obj \
	Image.obj \
	ImageList.obj \
	ImageHandlers.obj \
	InitDialogEvent.obj \
	KeyEvent.obj \
	LayoutWin.obj \
	ListBox.obj \
	ListCtrl.obj \
	Listbook.obj \
	Locale.obj \
	Log.obj \
	MDI.obj \
	MaximizeEvent.obj \
	MemoryDC.obj \
	Menu.obj \
	MenuBar.obj \
	MenuItem.obj \
	MessageDialog.obj \
	MiniFrame.obj \
	MouseCaptureChangedEvent.obj \
	MouseEvent.obj \
	MoveEvent.obj \
	NavigationKeyEvent.obj \
	NcPaintEvent.obj \
	Notebook.obj \
	NotebookSizer.obj \
	PaintEvent.obj \
	Palette.obj \
	PaletteChangedEvent.obj \
	Panel.obj \
	Pen.obj \
	PrintData.obj \
	PrintDialog.obj \
	PrintPreview.obj \
	Printer.obj \
	ProgressDialog.obj \
	QueryNewPaletteEvent.obj \
	RadioBox.obj \
	RadioButton.obj \
	Region.obj \
	SashWindow.obj \
	ScrollBar.obj \
	ScrolledWindow.obj \
	SetCursorEvent.obj \
	ShowEvent.obj \
	SizeEvent.obj \
	Sizer.obj \
	SizerItem.obj \
	Slider.obj \
	Sound.obj \
	SpinButton.obj \
	SpinCtrl.obj \
	SplashScreen.obj \
	SplitterWindow.obj \
	StaticBitmap.obj \
	StaticBox.obj \
	StaticBoxSizer.obj \
	StaticLine.obj \
	StaticText.obj \
	StatusBar.obj \
	StyledTextCtrl.obj \
	SysColourChangedEvent.obj \
	SystemSettings.obj \
	TabCtrl.obj \
	TaskBarIcon.obj \
	TextCtrl.obj \
	TextDialog.obj \
	Thread.obj \
	Timer.obj \
	TipDialog.obj \
	TipWindow.obj \
	ToggleButton.obj \
	ToolBar.obj \
	ToolTip.obj \
	TreeCtrl.obj \
	UpdateUIEvent.obj \
	Utils.obj \
	VLBox.obj \
	VScroll.obj \
	Validator.obj \
	VideoMode.obj \
	View.obj \
	Window.obj \
	WindowCreateEvent.obj \
	WindowDestroyEvent.obj \
	Wizard.obj \
	WizardPage.obj \
	WizardPageSimple.obj \
	wxDateTime.obj \
	wxObject.obj \
	wxString.obj \
	wxVersion.obj \
	wxPlatform.obj \
	Grid.obj \
	GridCtrl.obj \
	common.obj \
	ArrayInt.obj \
	ArrayString.obj \
	XmlResource.obj \
	NumberDialog.obj \
	aui\FrameManager.obj \
	aui\DockArt.obj \
	aui\aui.obj \
	wx.obj
	
#	DbGrid.obj \

WX_RELEASE_NODOT = 26
WX_VERSION = 2.6.4
PLATFORM = WXMSW
ENCODING = ANSI

include $(MAKESTUB)

all:  $(LIBTARGET)

DMD=dmd
DFLAGS=-O -g

$(LIBTARGET): $(OBJECTS)
	lib -p512 -c -n $@ $(OBJECTS)

VERSION=-version=wx$(WX_RELEASE_NODOT) -version=__$(PLATFORM)__ -version=$(ENCODING)

.d.obj:
	$(DMD) $(VERSION) -I.. $(DFLAGS) -c -of$@ $<

clean:
	-del *.obj aui\*.obj
	-del *.html aui\*.html
	-del $(LIBTARGET)


