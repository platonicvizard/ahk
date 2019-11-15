;============================================================
; MySQL class to enable connection and query to mysql database.
; The lvfill function can be used to automatically fill a gui listview with the output from an sql select.
; The database connection is automatically re-established if connection is lost (usually due to server restart or sql connection timeout)
; SQL error messages are automatically handled, but can be disabled if you wish.
; Connect and query calls return error and errstr.
;
; Multiple rows are separated by newline `n characters.
; Multiple columns are separated by pipe | characters.
;
; Copy the following files to your ahk project folder.
; So they can be found by the fileinstall command and properly embedded at compile time.
;    brokenlink.ico  (indicate missing file for icon file list)
;    libmysql.dll    (required to connect and make mysql query calls)
;
; EXAMPLE USAGE:
;
;    #include <mysql>    ; includes simple.ahk from lib 
;    mysql := new mysql     ; instantiates an object using this class
;    db := mysql.connect("sqlserver","userid","password","database")    ; connect to database
;    result := mysql.query(db, sql)    ; execute mysql select, update, delete, insert... etc) note: db will be updated if reconnect is needed
;============================================================ 

Class mysql {

    ;============================================================
    ; Connect to mysql database and return db handle
    ; 
    ;    host     = ip address or hostname of mysql server
    ;    user     = authorized userid for mysql connection
    ;    password = self explanitory
    ;    database = mysql database schema to connect to
    ;    errmsg   = 1-display errors in a msgbox, 0-no msgbox.. only return error and errstr
    ;============================================================
    
    connect(host,user,password,database,errmsg=1)
    {	
    
        this.host := host
        this.user := user
        this.password := password
        this.database := database
        
        RegExMatch(A_ScriptName, "^(.*?)\.", basename) 
        if Not InStr(FileExist(A_AppData "\" basename1), "D")    ; create appdata folder if doesnt exist
            FileCreateDir , % A_AppData "\" basename1

        libmysql = %A_AppData%\%basename1%\libmysql.dll  
            
        ; note: fileinstall must be called inside the functions.. it wont work in the header for library functions like it works in the main program!
        FileInstall, libmysql.dll, %libmysql%, 0   ; 0=no overwrite, 1=overwrite

        ;----------
        
        hModule := DllCall("LoadLibrary", "Str", libmysql)
        
        If (hModule = 0)
        {
            this.error := 9999
            this.errstr := "Can't load libmySQL.dll from directory " libmysql
            if errmsg
                msgbox, 16, % "MySQL Error: " this.error , % this.errstr "`n`n" sql 
            Return            
        }

        db := DllCall("libmySQL.dll\mysql_init", "UInt", 0)
                
        If (db = 0)
        {
            this.error := 9999
            this.errstr := "Not enough memory to connect to MySQL"
            if errmsg
                msgbox, 16, % "MySQL Error: " this.error , % this.errstr "`n`n" sql 
            Return 
        }
        
        connection := DllCall("libmySQL.dll\mysql_real_connect"
                , "UInt", db
                , "Str", host       ; host name
                , "Str", user       ; user name
                , "Str", password   ; password
                , "Str", database   ; database name
                , "UInt", 3306      ; port
                , "UInt", 0         ; unix_socket
                , "UInt", 0)        ; client_flag

        If (connection = 0)
        {
            this.error := DllCall("libmySQL.dll\mysql_errno", "UInt", db)
            this.errstr := DllCall("libmySQL.dll\mysql_error", "UInt", db, "Str")
            if errmsg
                msgbox, 16, % "MySQL Error: " this.error , % this.errstr "`n`n" sql 
            Return
        }

        serverVersion := DllCall("libmySQL.dll\mysql_get_server_info", "UInt", db, "Str")

        return db

    }

    ;============================================================
    ; mysql_query
    ;    _db    = database connection pointer returned from dbConnect call 
    ;    _query = sql query string.  can be a select, insert, update, delete ... etc
    ;    msg    = 1-display errors in a msgbox, 0-no msgbox.. only return error and errstr
    ;
    ;    if reconnect is needed then the new _db pointer is returned byref
    ;
    ;    returns error and errstr by way of associate array (eg. mysql.error and mysql.errstr)
    ;============================================================

    query(ByRef _db, _query, errmsg=1)
    {
        local resultString, result, requestResult, fieldCount
        local row, lengths, length, fieldPointer, field
        
        result := DllCall("libmySQL.dll\mysql_query", "UInt", _db , "Str", _query)
        
        this.error := 0
        this.errstr := ""
                
        If (result != 0) {
            errorcde := DllCall("libmySQL.dll\mysql_errno", "UInt", db)
            
            if (errorcde = 2003) or (errorcde = 2006) or (errorcde = 0) {     ; sql connection lost (2003) or sql connection timeout (2006)
                ; attempt sql reconnect
                _db := this.connect(this.host,this.user,this.password,this.database)   ; reconnect to mysql database
                    
                If (_db = "") {   ; reconnect failed
                    this.error := 2006
                    this.errstr := "MySQL server unavailable"
                    if errmsg
                        msgbox, 16, % "MySQL Error: " this.error , % this.errstr "`n`n" _query 
                    Return
                }
                
                result := DllCall("libmySQL.dll\mysql_query", "UInt", _db , "Str", _query) ; redo sql call
                
                If (result != 0) {   ; sql still failed after reconnect
                    this.error := DllCall("libmySQL.dll\mysql_errno", "UInt", db)
                    this.errstr := DllCall("libmySQL.dll\mysql_error", "UInt", db, "Str")
                    if errmsg
                        msgbox, 16, % "MySQL Error: " this.error , % this.errstr "`n`n" _query 
                    Return  
                }
                
            } else {    ; all other sql errors
                this.error := DllCall("libmySQL.dll\mysql_errno", "UInt", db)
                this.errstr := DllCall("libmySQL.dll\mysql_error", "UInt", db, "Str")
                if errmsg
                    msgbox, 16, % "MySQL Error: " this.error , % this.errstr "`n`n" _query                 
                Return            
            }
            
        }

        ; success... process results
        
        requestResult := DllCall("libmySQL.dll\mysql_store_result", "UInt", _db)

        if (requestResult = 0) {    ; call must have been an insert or delete ... a select would return results to pass back
            return
        }

        fieldCount := DllCall("libmySQL.dll\mysql_num_fields", "UInt", requestResult)

        Loop
        {
            row := DllCall("libmySQL.dll\mysql_fetch_row", "UInt", requestResult)
            If (row = 0 || row == "")
                Break

            ; Get a pointer on a table of lengths (unsigned long)
            lengths := DllCall("libmySQL.dll\mysql_fetch_lengths" , "UInt", requestResult)
                
            Loop %fieldCount%
            {
                length := this.GetUIntAtAddress(lengths, A_Index - 1)
                fieldPointer := this.GetUIntAtAddress(row, A_Index - 1)
                VarSetCapacity(field, length)
                DllCall("lstrcpy", "Str", field, "UInt", fieldPointer)
                resultString := resultString . field
                If (A_Index < fieldCount)
                    resultString := resultString . "|"     ; seperator for fields
            }

            resultString := resultString . "`n"          ; seperator for records  

        }

        ; remove last newline from resultString
        resultString := RegExReplace(resultString , "`n$", "") 	

        Return resultString
    }

    ;============================================================
    ; mysql get address
    ;============================================================ 

    GetUIntAtAddress(_addr, _offset)
    {
       local addr
       addr := _addr + _offset * 4
       Return *addr + (*(addr + 1) << 8) +  (*(addr + 2) << 16) + (*(addr + 3) << 24)
    }

    ;============================================================
    ; Escape mysql special characters
    ; This must be done to sql insert columns where the characters might contain special characters, such as user input fields
    ;
    ; Escape Sequence     Character Represented by Sequence
    ; \'     A single quote (“'”) character.
    ; \"     A double quote (“"”) character.
    ; \n     A newline (linefeed) character.
    ; \r     A carriage return character.
    ; \t     A tab character.
    ; \\     A backslash (“\”) character.
    ; \%     A “%” character. Usually indicates a wildcard character
    ; \_     A “_” character. Usually indicates a wildcard character
    ; \b     A backspace character.
    ;
    ; these 2 have not yet been included yet
    ; \Z     ASCII 26 (Control+Z). Stands for END-OF-FILE on Windows
    ; \0     An ASCII NUL (0x00) character.
    ;
    ; example call:
    ;     description := mysql_escape_string(description)
    ;============================================================

    escape_string(unescaped_string)
    {
        escaped_string := RegExReplace(unescaped_string, "\\", "\\")     ; \
        escaped_string := RegExReplace(escaped_string, "'", "\'")        ; '
        
        escaped_string := RegExReplace(escaped_string, "`t", "\t")       ; \t
        escaped_string := RegExReplace(escaped_string, "`n", "\n")       ; \n
        escaped_string := RegExReplace(escaped_string, "`r", "\r")       ; \r
        escaped_string := RegExReplace(escaped_string, "`b", "\b")       ; \b
        
        ; these characters appear to insert fine in mysql    
        ;escaped_string := RegExReplace(escaped_string, "%", "\%")        ; %
        ;escaped_string := RegExReplace(escaped_string, "_", "\_")        ; _
        ;escaped_string := RegExReplace(escaped_string, """", "\""")      ; "
        
        return escaped_string
    }
    
    ;============================================================
    ; fill listview with results from query 
    ; note: the current data in the listview is replaced with the new data
    ;
    ; inputs:
    ;    column names:  provide a comma delimited list of names to be used as column headers in the listview
    ;                   OR 
    ;                   provide the sql query string and column names will pulled from select clause
    ;                   (eg. "select name as User_Name from table" then column will be "User Name")
    ;                   (eg. "select name from table" then column will be "Name")
    ;
    ;                   Underscores are automatically removed from aliasname before displaying as column headers
    ;
    ;                   To hide a column put a $ at the end of the column name 
    ;                   (eg. "select name as User_Name$ from table")
    ;                
    ;                   If you include a column named "icon", then its value will be used to add an icon to the listview.
    ;                   The icon column should contain a full path to a file or folder to extract the icon from.
    ;
    ;                   If path is not found then brokenlink.ico will be used.
    ;                
    ;                 * Displaying icons significantly reduces performance and is only recommended for short lists.
    ;                   This is because the current logic stores a unique icon for each file, 
    ;                   even when there is already a file in the list with the same icon.  Perhaps in the future this logic can be added.
    ;
    ;    sql result:    provide data returned from mysql.query 
    ;                   (rows should be \n delimited and columns | delimited)
    ;
    ;    listview name
    ;
    ;    selectmode:    (optional) Important when refreshing an existing listview.  Set how to re-select the same row.
    ;                   0 = no re-select  (default)
    ;                   1 = select by column 1 value  (column 1 is assumed to be unique)
    ;                   2 = select by row number (recommended only if your list is relatively static)
    ;
    ;============================================================ 

    lvfill(sql, result, listviewname, selectmode=0)
    {
    
        ;-------------------------------------------
        ; delete all rows in listview
        ;-------------------------------------------
    
        GuiControl, -Redraw, %listviewname%     ; to improve performance, turn off redraw then turn back on at end
        
        Gui, ListView, %listviewname%    ; specify which listview will be updated with LV commands  
        
        if (selectmode = 1) {
            column1value := ""
            selectedrow := LV_GetNext(0)     ; get current selected row
            if selectedrow |= 0
                LV_GetText(column1value, selectedrow, 1) ; get column 1 value for current row          
        } else if (selectmode = 2) {
            selectedrow := LV_GetNext(0)     ; get current selected row
        }
        
        LV_Delete()  ; delete all rows in listview
        
        ;-------------------------------------------
        ; delete all pre-existing columns (must delete in reverse order because it is a shifting target)
        ;-------------------------------------------

        columncount := LV_GetCount("Column")

        if columncount > 0
            Loop, %columncount%
            {	
                LV_DeleteCol(columncount)
                columncount--
                if columncount = 0
                    break
            }
        
        ;-------------------------------------------
        ; create columns
        ;-------------------------------------------

        columns := this.sqlcolumns(sql)    ; get list of column names in comma delimited list
        
        totalcolumns := 0
        iconcolumn := 0
        Loop, parse, columns, CSV
        {	
            totalcolumns++
            
            ;colname := RegExReplace(A_LoopField, "\$", "")
            ;LV_DeleteCol(A_Index)   already deleted above
            
            LV_InsertCol(A_Index,"",A_LoopField)   ; create column with name from sql, but remove possible $ which indicates a hidden field
            
            if (A_LoopField = "icon$" ) {  ; detect optional icon column 
                iconcolumn := A_Index    ; save icon column number for later
                ; create imagelist for icons
                ImageListID := IL_Create(10)  ; Create an ImageList to hold small icons, this list can grow, so 10 is ok
                LV_SetImageList(ImageListID)  ; Assign the above ImageList to the current ListView.
                VarSetCapacity(Filename, 260)   ; Ensure the variable has enough capacity to hold the longest file path.
                sfi_size = 352
                VarSetCapacity(sfi, sfi_size)   ; This is done because ExtractAssociatedIconA() needs to be able to store a new filename in it.
            }
        }
        
        ;-------------------------------------------
        ; fileinstall brokenlink.ico to represent missing files in icon file list
        ;-------------------------------------------
        
        if (iconcolumn != 0) {
            RegExMatch(A_ScriptName, "^(.*?)\.", basename) 
            if Not InStr(FileExist(A_AppData "\" basename1), "D")    ; create appdata folder if doesnt exist
                FileCreateDir , % A_AppData "\" basename1

            file := "brokenlink.ico"
            brokenlink = %A_AppData%\%basename1%\brokenlink.ico  
            
            If FileExist( "./brokenlink.ico" ) {  ; if brokenlink.ico exists then install in appdata
                FileInstall, brokenlink.ico, %brokenlink%, 0   ; 0=no overwrite, 1=overwrite
            }
        }
        
        ;-------------------------------------------
        ; using first row values, set integer columns
        ;-------------------------------------------
        
        StringGetPos, pos, result, `n   ; extract first row from result
        StringLeft, row, result, pos
        Loop, parse, row, |
        {	
            StringReplace, data, A_LoopField, % " KB",,   ; remove " KB" so that column can be interpreted as an integer
            if data is integer
                LV_ModifyCol(A_Index, "Integer")  ; For sorting purposes, indicate column is an integer.
        }

        ;-------------------------------------------
        ; parse rows
        ;-------------------------------------------
        
        count := 0
        Loop, parse, result, `n
        {		
            
            IfEqual, A_LoopField, , Continue  ; Ignore blank rows (usually last row)

            LV_Add("") ; add blank row to listview
            
            StringSplit, array, A_LoopField, |      ; extract columns
            
            ; if icon column exists then use given path to create icon for current row
            if (iconcolumn != 0) {   
            
                iconpath := array%iconcolumn%     ; get column text
                
                ; Get the high-quality small-icon associated with this file extension:
                if DllCall("Shell32\SHGetFileInfoA", "str", iconpath, "uint", 0, "str", sfi, "uint", sfi_size, "uint", 0x101)  ; 0x101 is SHGFI_ICON+SHGFI_SMALLICON
                {
                    ; Extract the hIcon member from the structure:
                    hIcon = 0
                    Loop 4
                        hIcon += *(&sfi + A_Index-1) << 8*(A_Index-1)
                    ; Add the HICON directly to the small-icon and large-icon lists.
                    ; Below uses +1 to convert the returned index from zero-based to one-based:
                    IconNumber := DllCall("ImageList_ReplaceIcon", "uint", ImageListID, "int", -1, "uint", hIcon) + 1
                    DllCall("DestroyIcon", "uint", hIcon)   ; Now that it's been copied into the ImageLists, the original should be destroyed
                } else {
                    if DllCall("Shell32\SHGetFileInfoA", "str", brokenlink, "uint", 0, "str", sfi, "uint", sfi_size, "uint", 0x101)  ; 0x101 is SHGFI_ICON+SHGFI_SMALLICON
                    {
                        ; Extract the hIcon member from the structure:
                        hIcon = 0
                        Loop 4
                            hIcon += *(&sfi + A_Index-1) << 8*(A_Index-1)
                        ; Add the HICON directly to the small-icon and large-icon lists.
                        ; Below uses +1 to convert the returned index from zero-based to one-based:
                        IconNumber := DllCall("ImageList_ReplaceIcon", "uint", ImageListID, "int", -1, "uint", hIcon) + 1
                        DllCall("DestroyIcon", "uint", hIcon)   ; Now that it's been copied into the ImageLists, the original should be destroyed                
                    } else {
                        IconNumber := 9999999  ; Set it out of bounds to display a blank icon.
                    }
                }
                
                LV_Modify(A_Index, "Icon" . IconNumber)   ; set row icon             
            }
            
            row := A_Index
            
            ; populate columns of current row
            Loop, parse, columns, CSV     
            {
                data = col%A_index%      ; trick to indicate colx in following LV_Modify command
                LV_Modify(row,data,array%A_Index%)      ; update current column of current row
            }
                    
        }
        
        ;-------------------------------------------
        ; autosize columns: should be done outside the row loop to improve performance
        ;-------------------------------------------
        
        LV_ModifyCol()  ; Auto-size each column to fit its contents.
        Loop, parse, columns, CSV
        {	
            if (A_Index != totalcolumns)     ; do all except last column
                LV_ModifyCol(A_Index,"AutoHdr")   ; Autosize header.
            
            if RegExMatch(A_LoopField, "\$$")    ;If there is a $ at end of column name, that indicates a hidden column
                LV_ModifyCol(A_Index,0)   ; set width to 0 to create hidden column
            
        }
        
        ;LV_ModifyCol(2,0)    ; makes column 0 width... therefore, hidden
        
        Gui, Submit, NoHide               ; update v control variables	

        ; re-select logic

        if (selectmode = 1) {    ;reselect row by column1value
            if (column1value != "") {
                Loop % LV_GetCount()   ; loop through all rows in listview to find column1value
                {
                    LV_GetText(value, A_Index, 1)    ; get column1 value for current row

                    If (value = column1value) {
                        LV_Modify(A_Index, "+Select +Focus")     ; select originally selected row in list  
                        break
                    }
                }
            }
        } else if (selectmode = 2) {    ; reselect row by row number
            if (selectedrow != 0)
                LV_Modify(selectedrow, "+Select +Focus")     ; select originally selected row in list   
        }
        
        GuiControl, +Redraw, %listviewname%     ; to improve performance, turn off redraw at beginning then turn back on at end
        
        Return

    }

    ;============================================================ 
    ; lvread
    ; gets the contents of a listview and returns in result form (columns are | delimited and rows are `n delimited)
    ;============================================================ 

    lvread(listviewname)
    {
        Gui, ListView, %listviewname%    ; specify which listview will be updated with LV commands  
    
        result := ""
        
        Loop % LV_GetCount()   ; loop through all rows in listview 
        {
            row := A_Index

            Loop % LV_GetCount("Column")    ; loop through all columns
            {
                LV_GetText(value, row, A_Index)    ; get column value
            
                result .= value "|"  
            }
            
            result .= "`n"
        }
        
        return result
    }    
        
    ;============================================================
    ; extract column names from sql string and return in a comma delimited list
    ;============================================================ 

    sqlcolumns(sql)
    {
        sql := RegExReplace(sql , "\n", " ")    ; collapse multiline string ... replace \n with spaces
        sql := RegExReplace(sql , "\t", " ")    ; replace \t with space
        sql := RegExReplace(sql , "\s+", " ")   ; collapse multiple spaces to single space replace \s+ with " "
        sql := RegExReplace(sql , "\([^\(]+?\)", "")   ; remove parenthetical items because they may contain commas... 	
        sql := RegExReplace(sql , "\([^\(]+?\)", "")   ; run a second time to account for parens inside parens
        sql := RegExReplace(sql , "\([^\(]+?\)", "")   ; run a third time to account for parens inside parens (this will handle 3 levels deep for parens)
        
        if (RegExMatch(sql, "i)SELECT (.*?) FROM ", data) )     ; extract substring using regex and store subpatterns (.*) into data1, data2...etc
            selectclause := data1     
        else
            return sql     ; data does not contain select clause, so it may already be a comma delimited list
        

        columns := ""
        Loop, Parse, selectclause , CSV 
        {

            if A_LoopField =     ; skip blanks
                continue 
            
            item := RegExReplace(A_LoopField , "^\s+", "")    ; remove beginning spaces
            item := RegExReplace(item , "\s+$", "")           ; remove ending spaces
            
            ; find possible alias
            if (RegExMatch(item, "i).* as (.*)", alias)) { ; extract substring using regex and store subpatterns (.*) into data1, data2...etc
                aliasname := RegExReplace(alias1 , "_", " ")   ; replace possible underscores with spaces in aliasname
                columns = %columns%%aliasname%,
            } else {
                columns = %columns%%item%,
            }
            
        }
            
        ; remove last comma delimiter    
        columns := RegExReplace(columns , ",$", "") 

        return columns
    }

    ;============================================================
    ; return the text for a given columnName and row number
    ; Same as LV_GetText, except columnname can be given instead of column number
    ;============================================================

    lv_gettext2(ByRef OutputVar, RowNumber, ColumnName)
    {
        ; Find ColumnNumber for given ColumnName
        
        Loop % LV_GetCount("Column")
        {
            LV_GetText(name, 0, A_Index)  ; get column name  
            
            If (Name = ColumnName) {
                ; A_Index is the columnnumber
                LV_GetText(OutputVar, RowNumber, A_Index)
                return
            }
        }
        
        return 
    }    
}