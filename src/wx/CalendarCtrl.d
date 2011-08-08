//-----------------------------------------------------------------------------
// wxD - CalendarCtrl.d
// (C) 2005 bero <berobero.sourceforge.net>
// based on
// wx.NET - CalendarCtrl.cs
//
/// The wxCalendarCtrl wrapper class.
//
// Written by Bryan Bulten (bryan@bulten.ca)
// (C) 2003 Bryan Bulten
// Licensed under the wxWidgets license, see LICENSE.txt for details.
//
// $Id: CalendarCtrl.d,v 1.10 2010/10/11 09:31:36 afb Exp $
//-----------------------------------------------------------------------------

module wx.CalendarCtrl;
public import wx.common;
public import wx.wxDateTime;
public import wx.Colour;
public import wx.Font;
public import wx.Control;
public import wx.CommandEvent;

    public enum CalendarHitTestResult
    {
        wxCAL_HITTEST_NOWHERE,
        wxCAL_HITTEST_HEADER,
        wxCAL_HITTEST_DAY,
        wxCAL_HITTEST_INCMONTH,
        wxCAL_HITTEST_DECMONTH,
        wxCAL_HITTEST_SURROUNDING_WEEK
    }

    public enum CalendarDateBorder
    {
        wxCAL_BORDER_NONE,
        wxCAL_BORDER_SQUARE,
        wxCAL_BORDER_ROUND
    }

		//! \cond EXTERN
        static extern (C) IntPtr wxCalendarCtrl_ctor();
        static extern (C) bool   wxCalendarCtrl_Create(IntPtr self, IntPtr parent, int id, IntPtr date, ref Point pos, ref Size size, uint style, string name);
        static extern (C) bool   wxCalendarCtrl_SetDate(IntPtr self, IntPtr date);
        static extern (C) IntPtr wxCalendarCtrl_GetDate(IntPtr self);
        static extern (C) bool   wxCalendarCtrl_SetLowerDateLimit(IntPtr self, IntPtr date);
        static extern (C) IntPtr wxCalendarCtrl_GetLowerDateLimit(IntPtr self);
        static extern (C) bool   wxCalendarCtrl_SetUpperDateLimit(IntPtr self, IntPtr date);
        static extern (C) IntPtr wxCalendarCtrl_GetUpperDateLimit(IntPtr self);
        static extern (C) bool   wxCalendarCtrl_SetDateRange(IntPtr self, IntPtr lowerdate, IntPtr upperdate);
        static extern (C) void   wxCalendarCtrl_EnableYearChange(IntPtr self, bool enable);
        static extern (C) void   wxCalendarCtrl_EnableMonthChange(IntPtr self, bool enable);
        static extern (C) void   wxCalendarCtrl_EnableHolidayDisplay(IntPtr self, bool display);
        static extern (C) void   wxCalendarCtrl_SetHeaderColours(IntPtr self, IntPtr colFg, IntPtr colBg);
        static extern (C) IntPtr wxCalendarCtrl_GetHeaderColourFg(IntPtr self);
        static extern (C) IntPtr wxCalendarCtrl_GetHeaderColourBg(IntPtr self);
        static extern (C) void   wxCalendarCtrl_SetHighlightColours(IntPtr self, IntPtr colFg, IntPtr colBg);
        static extern (C) IntPtr wxCalendarCtrl_GetHighlightColourFg(IntPtr self);
        static extern (C) IntPtr wxCalendarCtrl_GetHighlightColourBg(IntPtr self);
        static extern (C) void   wxCalendarCtrl_SetHolidayColours(IntPtr self, IntPtr colFg, IntPtr colBg);
        static extern (C) IntPtr wxCalendarCtrl_GetHolidayColourFg(IntPtr self);
        static extern (C) IntPtr wxCalendarCtrl_GetHolidayColourBg(IntPtr self);
        static extern (C) IntPtr wxCalendarCtrl_GetAttr(IntPtr self, int day);
        static extern (C) void   wxCalendarCtrl_SetAttr(IntPtr self, int day, IntPtr attr);
        static extern (C) void   wxCalendarCtrl_SetHoliday(IntPtr self, int day);
        static extern (C) void   wxCalendarCtrl_ResetAttr(IntPtr self, int day);
        static extern (C) int    wxCalendarCtrl_HitTest(IntPtr self, ref Point pos, IntPtr date, ref DayOfWeek wd);
		//! \endcond

        //-----------------------------------------------------------------------------

    alias CalendarCtrl wxCalendarCtrl;
    public class CalendarCtrl : Control
    {
        enum
        {
            // show Sunday as the first day of the week (default)
            wxCAL_SUNDAY_FIRST               = 0x0000,

            // show Monday as the first day of the week
            wxCAL_MONDAY_FIRST               = 0x0001,

            // highlight holidays
            wxCAL_SHOW_HOLIDAYS              = 0x0002,

            // disable the year change control, show only the month change one
            wxCAL_NO_YEAR_CHANGE             = 0x0004,

            // don't allow changing neither month nor year (implies
            // wxCAL_NO_YEAR_CHANGE)
            wxCAL_NO_MONTH_CHANGE            = 0x000c,

            // use MS-style month-selection instead of combo-spin combination
            wxCAL_SEQUENTIAL_MONTH_SELECTION = 0x0010,

            // show the neighbouring weeks in the previous and next month
            wxCAL_SHOW_SURROUNDING_WEEKS     = 0x0020
        }
        
	public const string wxCalendarNameStr  = "CalendarCtrl";
        //-----------------------------------------------------------------------------

        public this(IntPtr wxobj)
            { super(wxobj); }
	    
        public this()
            { this(wxCalendarCtrl_ctor()); }

        public this(Window parent, int id, wxDateTime date = null /*wxDefaultDateTime*/, Point pos = wxDefaultPosition, Size size =wxDefaultSize , int style = wxCAL_SHOW_HOLIDAYS | wxWANTS_CHARS, string name = wxCalendarNameStr)
        {
        	this(wxCalendarCtrl_ctor());
            if (!Create(parent, id, date, pos, size, style, name))
            {
				throw new InvalidOperationException("Failed to create CalendarCtrl");
            }
        }
	
	//-----------------------------------------------------------------------------
	// ctors with self created id
	
        public this(Window parent, DateTime date = null, Point pos = wxDefaultPosition, Size size =wxDefaultSize , int style = wxCAL_SHOW_HOLIDAYS | wxWANTS_CHARS, string name = wxCalendarNameStr)
		{ this(parent, Window.UniqueID, date, pos, size, style, name);}
		
	//-----------------------------------------------------------------------------

        public bool Create(Window parent, int id, wxDateTime date, ref Point pos, ref Size size, int style, string name)
        {
            return wxCalendarCtrl_Create(wxobj, wxObject.SafePtr(parent), id, wxObject.SafePtr(date), pos, size, cast(uint)style, name);
        }

        //-----------------------------------------------------------------------------

        public void Date(DateTime value) { wxCalendarCtrl_SetDate(wxobj, wxObject.SafePtr(cast(wxDateTime)value)); }
        public DateTime Date() { return new wxDateTime(wxCalendarCtrl_GetDate(wxobj)); }

        //-----------------------------------------------------------------------------

        public void LowerDateLimit(DateTime value) { wxCalendarCtrl_SetLowerDateLimit(wxobj, wxObject.SafePtr(cast(wxDateTime)value)); }
        public DateTime LowerDateLimit() { return new wxDateTime(wxCalendarCtrl_GetLowerDateLimit(wxobj)); }

        public void UpperDateLimit(DateTime value) { wxCalendarCtrl_SetUpperDateLimit(wxobj, wxObject.SafePtr(cast(wxDateTime)value)); }
        public DateTime UpperDateLimit() { return new wxDateTime(wxCalendarCtrl_GetUpperDateLimit(wxobj)); }

        //-----------------------------------------------------------------------------

        public bool SetDateRange(DateTime lowerdate, DateTime upperdate)
        {
            return wxCalendarCtrl_SetDateRange(wxobj, wxObject.SafePtr(cast(wxDateTime)lowerdate), wxObject.SafePtr(cast(wxDateTime)upperdate));
        }

        //-----------------------------------------------------------------------------

        public void EnableYearChange(bool value) { wxCalendarCtrl_EnableYearChange(wxobj, value); }

        public void EnableMonthChange(bool value) { wxCalendarCtrl_EnableMonthChange(wxobj, value); }

        public void EnableHolidayDisplay(bool value) { wxCalendarCtrl_EnableHolidayDisplay(wxobj, value); }

        //-----------------------------------------------------------------------------

        public void SetHeaderColours(Colour colFg, Colour colBg)
        {
            wxCalendarCtrl_SetHeaderColours(wxobj, wxObject.SafePtr(colFg), wxObject.SafePtr(colBg));
        }

        public Colour HeaderColourFg() { return new Colour(wxCalendarCtrl_GetHeaderColourFg(wxobj), true); }

        public Colour HeaderColourBg() { return new Colour(wxCalendarCtrl_GetHeaderColourBg(wxobj), true); }

        //-----------------------------------------------------------------------------

        public void SetHighlightColours(Colour colFg, Colour colBg)
        {
            wxCalendarCtrl_SetHighlightColours(wxobj, wxObject.SafePtr(colFg), wxObject.SafePtr(colBg));
        }

        public Colour HighlightColourFg() { return new Colour(wxCalendarCtrl_GetHighlightColourFg(wxobj)); }

        public Colour HighlightColourBg() { return new Colour(wxCalendarCtrl_GetHighlightColourBg(wxobj)); }

        //-----------------------------------------------------------------------------

        public void SetHolidayColours(Colour colFg, Colour colBg)
        {
            wxCalendarCtrl_SetHolidayColours(wxobj, wxObject.SafePtr(colFg), wxObject.SafePtr(colBg));
        }

        public Colour HolidayColourFg() { return new Colour(wxCalendarCtrl_GetHolidayColourFg(wxobj)); }

        public Colour HolidayColourBg() { return new Colour(wxCalendarCtrl_GetHolidayColourBg(wxobj)); }

        //-----------------------------------------------------------------------------

        public CalendarDateAttr GetAttr(int day)
        {
            return cast(CalendarDateAttr)FindObject(wxCalendarCtrl_GetAttr(wxobj, day), &CalendarDateAttr.New);
        }

        public void SetAttr(int day, CalendarDateAttr attr)
        {
            wxCalendarCtrl_SetAttr(wxobj, day, wxObject.SafePtr(attr));
        }

        //-----------------------------------------------------------------------------

        public void SetHoliday(int day)
        {
            wxCalendarCtrl_SetHoliday(wxobj, day);
        }

        //-----------------------------------------------------------------------------

        public void ResetAttr(int day)
        {
            wxCalendarCtrl_ResetAttr(wxobj, day);
        }

        //-----------------------------------------------------------------------------

        public CalendarHitTestResult HitTest(Point pos, ref DateTime date, ref DayOfWeek wd)
        {
            wxDateTime dt = date;
            CalendarHitTestResult res = cast(CalendarHitTestResult)wxCalendarCtrl_HitTest(wxobj, pos, wxObject.SafePtr(dt), wd);
            date = dt;

            return res;
        }

        //-----------------------------------------------------------------------------

		public void SelectionChange_Add(EventListener value) { AddCommandListener(Event.wxEVT_CALENDAR_SEL_CHANGED, ID, value, this); }
		public void SelectionChange_Remove(EventListener value) { RemoveHandler(value, this); }

		public void DayChange_Add(EventListener value) { AddCommandListener(Event.wxEVT_CALENDAR_DAY_CHANGED, ID, value, this); }
		public void DayChange_Remove(EventListener value) { RemoveHandler(value, this); }

		public void MonthChange_Add(EventListener value) { AddCommandListener(Event.wxEVT_CALENDAR_MONTH_CHANGED, ID, value, this); }
		public void MonthChange_Remove(EventListener value) { RemoveHandler(value, this); }

		public void YearChange_Add(EventListener value) { AddCommandListener(Event.wxEVT_CALENDAR_YEAR_CHANGED, ID, value, this); }
		public void YearChange_Remove(EventListener value) { RemoveHandler(value, this); }

		public void DoubleClick_Add(EventListener value) { AddCommandListener(Event.wxEVT_CALENDAR_DOUBLECLICKED, ID, value, this); }
		public void DoubleClick_Remove(EventListener value) { RemoveHandler(value, this); }

		public void WeekdayClick_Add(EventListener value) { AddCommandListener(Event.wxEVT_CALENDAR_WEEKDAY_CLICKED, ID, value, this); }
		public void WeekdayClick_Remove(EventListener value) { RemoveHandler(value, this); }
    }

		//! \cond EXTERN
        static extern (C) IntPtr wxCalendarDateAttr_ctor();
        static extern (C) IntPtr wxCalendarDateAttr_ctor2(IntPtr colText, IntPtr colBack, IntPtr colBorder, IntPtr font, CalendarDateBorder border);
        static extern (C) IntPtr wxCalendarDateAttr_ctor3(CalendarDateBorder border, IntPtr colBorder);
	static extern (C) void   wxCalendarDateAttr_dtor(IntPtr self);
	static extern (C) void   wxCalendarDateAttr_RegisterDisposable(IntPtr self, Virtual_Dispose onDispose);
        static extern (C) void   wxCalendarDateAttr_SetTextColour(IntPtr self, IntPtr colText);
        static extern (C) void   wxCalendarDateAttr_SetBackgroundColour(IntPtr self, IntPtr colBack);
        static extern (C) void   wxCalendarDateAttr_SetBorderColour(IntPtr self, IntPtr col);
        static extern (C) void   wxCalendarDateAttr_SetFont(IntPtr self, IntPtr font);
        static extern (C) void   wxCalendarDateAttr_SetBorder(IntPtr self, int border);
        static extern (C) void   wxCalendarDateAttr_SetHoliday(IntPtr self, bool holiday);
        static extern (C) bool   wxCalendarDateAttr_HasTextColour(IntPtr self);
        static extern (C) bool   wxCalendarDateAttr_HasBackgroundColour(IntPtr self);
        static extern (C) bool   wxCalendarDateAttr_HasBorderColour(IntPtr self);
        static extern (C) bool   wxCalendarDateAttr_HasFont(IntPtr self);
        static extern (C) bool   wxCalendarDateAttr_HasBorder(IntPtr self);
        static extern (C) bool   wxCalendarDateAttr_IsHoliday(IntPtr self);
        static extern (C) IntPtr wxCalendarDateAttr_GetTextColour(IntPtr self);
        static extern (C) IntPtr wxCalendarDateAttr_GetBackgroundColour(IntPtr self);
        static extern (C) IntPtr wxCalendarDateAttr_GetBorderColour(IntPtr self);
        static extern (C) IntPtr wxCalendarDateAttr_GetFont(IntPtr self);
        static extern (C) int    wxCalendarDateAttr_GetBorder(IntPtr self);
		//! \endcond
	
        //-----------------------------------------------------------------------------

    alias CalendarDateAttr wxCalendarDateAttr;
    public class CalendarDateAttr : wxObject
    {
        public this(IntPtr wxobj)
	{ 
		super(wxobj);
	}
	
	private this(IntPtr wxobj, bool memOwn)
	{ 
		super(wxobj);
		this.memOwn = memOwn;
	}

        public this()
	{ 
		this(wxCalendarDateAttr_ctor(), true);
		wxCalendarDateAttr_RegisterDisposable(wxobj, &VirtualDispose);
	}

        public this(Colour colText, Colour colBack = Colour.wxNullColour, Colour colBorder = Colour.wxNullColour, Font font = Font.wxNullFont, CalendarDateBorder border = CalendarDateBorder.wxCAL_BORDER_NONE)
        {
        	this(wxCalendarDateAttr_ctor2(wxObject.SafePtr(colText), wxObject.SafePtr(colBack), wxObject.SafePtr(colBorder), wxObject.SafePtr(font), border),true);
		wxCalendarDateAttr_RegisterDisposable(wxobj, &VirtualDispose);
        }

        public  this(CalendarDateBorder border, Colour colBorder)
        {
        	this(wxCalendarDateAttr_ctor3(border, wxObject.SafePtr(colBorder)),true);
		wxCalendarDateAttr_RegisterDisposable(wxobj, &VirtualDispose);
        }
	
	//---------------------------------------------------------------------
				
	override protected void dtor() { wxCalendarDateAttr_dtor(wxobj); }

        //-----------------------------------------------------------------------------

        public void TextColour(Colour value) { wxCalendarDateAttr_SetTextColour(wxobj, wxObject.SafePtr(value)); }
        public Colour TextColour() { return new Colour(wxCalendarDateAttr_GetTextColour(wxobj)); }

        //-----------------------------------------------------------------------------

        public void BackgroundColour(Colour value) { wxCalendarDateAttr_SetBackgroundColour(wxobj, wxObject.SafePtr(value)); }
        public Colour BackgroundColour() { return new Colour(wxCalendarDateAttr_GetBackgroundColour(wxobj)); }

        //-----------------------------------------------------------------------------

        public void BorderColour(Colour value) { wxCalendarDateAttr_SetBorderColour(wxobj, wxObject.SafePtr(value)); }
        public Colour BorderColour() { return new Colour(wxCalendarDateAttr_GetBorderColour(wxobj)); }

        //-----------------------------------------------------------------------------

        public void font(Font value) { wxCalendarDateAttr_SetFont(wxobj, wxObject.SafePtr(value)); }
        public Font font() { return new Font(wxCalendarDateAttr_GetFont(wxobj)); }

        //-----------------------------------------------------------------------------

        public void Border(CalendarDateBorder value) { wxCalendarDateAttr_SetBorder(wxobj, cast(int)value); }
        public CalendarDateBorder Border() { return cast(CalendarDateBorder)wxCalendarDateAttr_GetBorder(wxobj); }

        //-----------------------------------------------------------------------------

        public void IsHoliday(bool value) { wxCalendarDateAttr_SetHoliday(wxobj, value); }
        public bool IsHoliday() { return wxCalendarDateAttr_IsHoliday(wxobj); }

        //-----------------------------------------------------------------------------

        public bool HasTextColour() { return wxCalendarDateAttr_HasTextColour(wxobj); }

        public bool HasBackgroundColour() { return wxCalendarDateAttr_HasBackgroundColour(wxobj); }

        public bool HasBorderColour() { return wxCalendarDateAttr_HasBorderColour(wxobj); }

        public bool HasFont() { return wxCalendarDateAttr_HasFont(wxobj); }

        public bool HasBorder() { return wxCalendarDateAttr_HasBorder(wxobj); }


	public static wxObject New(IntPtr ptr) { return new CalendarDateAttr(ptr); }
        //-----------------------------------------------------------------------------
    }

		//! \cond EXTERN
        static extern (C) IntPtr wxCalendarEvent_ctor();
        static extern (C) IntPtr wxCalendarEvent_ctor2(IntPtr cal, int type);
        static extern (C) IntPtr wxCalendarEvent_GetDate(IntPtr self);
        static extern (C) int    wxCalendarEvent_GetWeekDay(IntPtr self);
		//! \endcond

        //-----------------------------------------------------------------------------
	
    alias CalendarEvent wxCalendarEvent;
    public class CalendarEvent : CommandEvent
    {
	public this(IntPtr wxobj)
		{ super(wxobj);}

        public this()
            { super(wxCalendarEvent_ctor()); }

        //-----------------------------------------------------------------------------

        public this(CalendarCtrl cal, EventType type)
            { super(wxCalendarEvent_ctor2(wxObject.SafePtr(cal), type)); }

        //-----------------------------------------------------------------------------

        public DateTime Date() { return new wxDateTime(wxCalendarEvent_GetDate(wxobj)); }

        public DayOfWeek WeekDay() { return cast(DayOfWeek)wxCalendarEvent_GetWeekDay(wxobj); }

		private static Event New(IntPtr obj) { return new CalendarEvent(obj); }

		static this()
		{
			wxEVT_CALENDAR_SEL_CHANGED = wxEvent_EVT_CALENDAR_SEL_CHANGED();
			wxEVT_CALENDAR_DAY_CHANGED = wxEvent_EVT_CALENDAR_DAY_CHANGED();
			wxEVT_CALENDAR_MONTH_CHANGED = wxEvent_EVT_CALENDAR_MONTH_CHANGED();
			wxEVT_CALENDAR_YEAR_CHANGED = wxEvent_EVT_CALENDAR_YEAR_CHANGED();
			wxEVT_CALENDAR_DOUBLECLICKED = wxEvent_EVT_CALENDAR_DOUBLECLICKED();
			wxEVT_CALENDAR_WEEKDAY_CLICKED = wxEvent_EVT_CALENDAR_WEEKDAY_CLICKED();
	
			AddEventType(wxEVT_CALENDAR_SEL_CHANGED,            &CalendarEvent.New);
			AddEventType(wxEVT_CALENDAR_DAY_CHANGED,            &CalendarEvent.New);
			AddEventType(wxEVT_CALENDAR_MONTH_CHANGED,          &CalendarEvent.New);
			AddEventType(wxEVT_CALENDAR_YEAR_CHANGED,           &CalendarEvent.New);
			AddEventType(wxEVT_CALENDAR_DOUBLECLICKED,          &CalendarEvent.New);
			AddEventType(wxEVT_CALENDAR_WEEKDAY_CLICKED,        &CalendarEvent.New);
		}
    }

