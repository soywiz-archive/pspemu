//-----------------------------------------------------------------------------
// wxD - DbGrid.d
// (C) 2005 bero <berobero@users.sourceforge.net>
// based on
// wx.NET - DbGrid
//
/// The DbGrid class.
//
// Written by Alexander Olk (xenomorph2@onlinehome.de)
// (C) 2003 by Alexander Olk
// Licensed under the wxWidgets license, see LICENSE.txt for details.
// 
// $Id: DbGrid.d,v 1.9 2006/11/17 15:20:59 afb Exp $
//-----------------------------------------------------------------------------

module wx.DbGrid;
public import wx.common;
public import wx.Grid;

	alias Column wxColumn;
	public class Column
	{
		private string dbcolumnname;
		private string newcolumnname;
		private int width;

		//-----------------------------------------------------------------------------

		public this() {}

		//-----------------------------------------------------------------------------

		public string dbColumnName() { return dbcolumnname; }
		public void dbColumnName(string value) { dbcolumnname = value; }

		//-----------------------------------------------------------------------------

		public string newColumnName() { return newcolumnname; }
		public void newColumnName(string value) { newcolumnname = value; }

		//-----------------------------------------------------------------------------

		public int Width() { return width; }
		public void Width(int value) { width = value; }
	}

	//-----------------------------------------------------------------------------

	alias ColumnMapping wxColumnMapping;
	public class ColumnMapping
	{
		private Column[] cols;

		private int DEFAULT_COLUMN_WIDTH = 75;

		//-----------------------------------------------------------------------------

		public this()
		{
			cols = new ArrayList();
		}

		//-----------------------------------------------------------------------------

		public void Add(string dbcolumnname, string newcolumnname)
		{
			Add(dbcolumnname, newcolumnname, DEFAULT_COLUMN_WIDTH);
		}

		public void Add(string dbcolumnname, string newcolumnname, int width)
		{
			Column col = new Column();
			col.dbColumnName = dbcolumnname;
			col.newColumnName = newcolumnname;
			col.Width = width;
			cols =~ col;
		}

		//-----------------------------------------------------------------------------

		public uint length() { return cols.length; }

		//-----------------------------------------------------------------------------

		public Column opIndex(int index)
		{
			return cols[index];
		}

		//-----------------------------------------------------------------------------

		public Column Search(string dbcolumnname)
		{
			Column result = null;
			foreach (Column col;cols) 
			{
				if (col.dbColumnName == dbcolumnname)
				{
					result =  col;
					break;
				}
			}
			return result;
		}

		//-----------------------------------------------------------------------------

		public Column SearchDbColumnName(string newcolumnname)
		{
			Column result = null;
			foreach (Column col;cols) 
			{
				if (col.newColumnName.Equals(newcolumnname))
				{
					result =  col;
					break;
				}
			}
			return result;
		}		
		
		//-----------------------------------------------------------------------------
		
		public Column[] Cols() { return cols; }

		//-----------------------------------------------------------------------------

		public int DefaultColumnWidth() { return DEFAULT_COLUMN_WIDTH; }
		public void DefaultColumnWidth(int value) { DEFAULT_COLUMN_WIDTH = value; }
	}
	
	//-----------------------------------------------------------------------------

	public enum DbGridMsg
	{
		OK = 1,
		GRID_CREATION_ERROR,
		NO_TABLE_ERROR,
		NO_COLUMN_ERROR,
		NO_COLUMN_MAPPING_ERROR
	}

	//-----------------------------------------------------------------------------

	alias DbGrid wxDbGrid;
	public class DbGrid : Grid
	{
		private DataSet myDataSet = null;
		private ColumnMapping colmap = null;
		
		private string tablename;
		
		private bool datasetorcolmap = false; // if false, then dataset mapping else column mapping
		
		//-----------------------------------------------------------------------------
		
		public this(IntPtr wxobj)
			{ super(wxobj);}

		public this(Window parent, int id)
			{ this(parent, id, wxDefaultPosition, wxDefaultSize, wxWANTS_CHARS, "grid"); }

		public this(Window parent, int id, Point pos)
			{ this(parent, id, pos, wxDefaultSize, wxWANTS_CHARS, "grid"); }

		public this(Window parent, int id, Point pos, Size size)
			{ this(parent, id, pos, size, wxWANTS_CHARS, "grid"); }

		public this(Window parent, int id, Point pos, Size size, int style)
			{ this(parent, id, pos, size, style, "grid"); }

		public this(Window parent, int id, Point pos, Size size, int style, string name)
		{
			super(parent, id, pos, size, style, name);
			myDataSet = new DataSet();
			colmap = new ColumnMapping();

			EVT_GRID_CELL_CHANGE(new EventListener(OnGridCellChange));
		}
		
		//---------------------------------------------------------------------
		// ctors with self created id
		
		public this(Window parent)
			{ this(parent, Window.UniqueID, wxDefaultPosition, wxDefaultSize, wxWANTS_CHARS, "grid"); }

		public this(Window parent, Point pos)
			{ this(parent, Window.UniqueID, pos, wxDefaultSize, wxWANTS_CHARS, "grid"); }

		public this(Window parent, Point pos, Size size)
			{ this(parent, Window.UniqueID, pos, size, wxWANTS_CHARS, "grid"); }

		public this(Window parent, Point pos, Size size, int style)
			{ this(parent, Window.UniqueID, pos, size, style, "grid"); }

		public this(Window parent, Point pos, Size size, int style, string name)
			{ this(parent, Window.UniqueID, pos, size, style, name);}
		
		//-----------------------------------------------------------------------------

		public DataSet dataSet() { return myDataSet; }
		public void dataSet(DataSet value) { myDataSet = value; }
		
		//-----------------------------------------------------------------------------
		
		public ColumnMapping columnMapping() { return colmap; }
		public void columnMapping(ColumnMapping value) { colmap = value; }
		
		//-----------------------------------------------------------------------------
		
		public int DefaultColumnWidth() { return colmap.DefaultColumnWidth; }
		public void DefaultColumnWidth(int value) { colmap.DefaultColumnWidth = value; }
		
		//-----------------------------------------------------------------------------
		
		public void AddColumnMapping(string dbcolumnname, string newcolumnname)
		{
			colmap.Add(dbcolumnname, newcolumnname);
		}
		
		//-----------------------------------------------------------------------------
		
		public void AddColumnMapping(string dbcolumnname, string newcolumnname, int width)
		{
			colmap.Add(dbcolumnname, newcolumnname, width);
		}

		//-----------------------------------------------------------------------------
		
		// Create the grid, map columnnames
		// grid columns equal dataset columns
		public DbGridMsg CreateGridFromDataSet(string tablename)
		{
			if (dataSet != null) 
			{
				// No tables;dataset
				if (dataSet.Tables.Count == 0)
				{
					return DbGridMsg.NO_TABLE_ERROR;
				}
				
				// No columns;dataset
				if (dataSet.Tables[tablename].Columns.Count == 0)
				{
					return DbGridMsg.NO_COLUMN_ERROR;
				}
				
				datasetorcolmap = false;
				
				this.tablename = tablename;
				int r = 0;
				int c = 0;
				DataTable table = dataSet.Tables[tablename];
				int numcols = table.Columns.Count;
				
				if ( !CreateGrid(table.Rows.Count, numcols) )
				{
					return DbGridMsg.GRID_CREATION_ERROR;
				}
				
				RowLabelSize = 0; 
				
				// If a mapping name exists use mapping name
				// else use dataset column caption
				foreach (DataColumn col;table.Columns) 
				{
					Column icol = colmap.Search(col.Caption);
					
					string ncolname=col.Caption;
					
					if (icol != null)
					{
						if (icol.newColumnName.Length > 0)
						{
							ncolname = icol.newColumnName;
						}

						SetColumnWidth(c, icol.Width);
					}
						
					SetColLabelValue(c, ncolname);
					c++;
				}	
				
				// Fill grid
				foreach (DataRow row;table.Rows) 
				{
					c = 0;					
					foreach (DataColumn col;table.Columns) 
					{
						SetCellValue(r, c, row[col].ToString());
						c++;
					}
					r++;
				}
			}			

			return DbGridMsg.OK;
		}
		
		//-----------------------------------------------------------------------------
		
		// Create the grid, map columnnames
		// grid columns equal ColumnMapping columns
		public DbGridMsg CreateGridFromColumnMapping(string tablename)
		{
			if (dataSet != null) 
			{
				// No tables;dataset
				if (dataSet.Tables.Count == 0)
				{
					return DbGridMsg.NO_TABLE_ERROR;
				}
				
				// No columns;dataset
				if (dataSet.Tables[tablename].Columns.Count == 0)
				{
					return DbGridMsg.NO_COLUMN_ERROR;
				}
				
				// No columns;colmap
				if ( colmap.Count == 0 )
				{
					return DbGridMsg.NO_COLUMN_MAPPING_ERROR;
				}
				
				datasetorcolmap = true;
				
				this.tablename = tablename;
				int r = 0;
				int c = 0;
				DataTable table = dataSet.Tables[tablename];
				int numcols = colmap.Count;
				
				if ( !CreateGrid(table.Rows.Count, numcols) )
				{
					return DbGridMsg.GRID_CREATION_ERROR;
				}
				
				RowLabelSize = 0; 
				
				// Grid column names = colmap newColumnName
				foreach (Column icol;colmap.Cols) 
				{					
					SetColumnWidth(c, icol.Width);
						
					SetColLabelValue(c, icol.newColumnName);
					c++;
				}	
				
				// Fill grid
				foreach (DataRow row;table.Rows) 
				{
					c = 0;		
					foreach (Column col;colmap.Cols) 
					{					
						SetCellValue(r, c, row[col.dbColumnName].ToString());
						c++;
					}
					r++;
				}
			}			

			return DbGridMsg.OK;
		}
		
		//-----------------------------------------------------------------------------

		// currently this only works manually
		// you have to call it from the application
		// it will add a new row to the grid and the datatable;the dataset
		public void AddRow()
		{
			AppendRows(1, true);
			DataRow nrow = myDataSet.Tables[tablename].NewRow();
			myDataSet.Tables[tablename].Rows.Add(nrow);
		}
		
		//-----------------------------------------------------------------------------
		
		// Returns the currently selected row
		public DataRow GetRow(int num)
		{
			DataRow dr = null;
			
			try
			{			
				dr = myDataSet.Tables[tablename].Rows[num];
			}
			catch (Exception e)
			{
				dr = null;
			}
			
			return dr;
		}
		
		//-----------------------------------------------------------------------------		
		
		// Cell change ?? Change the corresponding dataset also
		private void OnGridCellChange(Object sender, Event e)
		{
			GridEvent ge = cast(GridEvent)e;
			string s = GetColLabelValue(ge.Col);		
			DataRow row = myDataSet.Tables[tablename].Rows[ge.Row];			
			row[s] = GetCellValue(ge.Row, ge.Col);
		}
		
		//-----------------------------------------------------------------------------
	}
