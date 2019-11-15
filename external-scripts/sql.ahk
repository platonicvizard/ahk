;====================================================================
; 
; Demo of mysql library
;
; You must create a new database schema in mysql called "demo" and create a user with privileges to it.
; This demo app will create a table and present a simple gui to add records to the table.
;
; Programmer: Alan Lilly (alilly@rttusa.com) 
; AutoHotkey: v1.1.04.00 (autohotkey_L ANSI version)
;
;====================================================================

#SingleInstance force
#NoENV              ; Avoids checking empty variables to see if they are environment variables (recommended for all new scripts and increases performance).
SetBatchLines -1    ; have the script run at maximum speed and never sleep
ListLines Off       ; a debugging option

;outputdebug DBGVIEWCLEAR

;#include <mysql>      ; pull from library
#include mysql.ahk     ; pull from local directory

;============================================================
; make database connection to mysql 
;============================================================ 

mysql := new mysql      ; instantiates an object using this class

; note host can be hostname or ip address
db := mysql.connect("10.11.3.85","alan","password","demo")     ; host,user,password,database

if db =
    return

;============================================================
; create address table
; if table already exists we ignore the error because we set errmsg = 0
;============================================================ 

sql =
(
    CREATE TABLE address (
        name VARCHAR(50) NULL,
        address VARCHAR(50) NULL,
        city VARCHAR(50) NULL,
        state VARCHAR(2) NULL,
        zip INT(5) NULL,
        PRIMARY KEY (name)  )
    COLLATE='latin1_swedish_ci'
    ENGINE=InnoDB
    ROW_FORMAT=DEFAULT
)


fullname := mysql.query(db, sql, 0)

;if (mysql.error) {
;    msgbox, 16, % "MySQL Error: " mysql.error , % mysql.errstr "`n`n" sql      
;    exitapp
;}

;============================================================
; Build gui:
;============================================================ 

Gui, 1:Default 

Gui, Add, Text, section right w70, Name
Gui, Add, Edit, x+10 w150 vname

Gui, Add, Text, xs right w70, Address
Gui, Add, Edit, x+10 w250 vaddress

Gui, Add, Text, xs right w70, City
Gui, Add, Edit, x+10 w150 vcity

Gui, Add, Text, xs right w70, State
Gui, Add, Edit, x+10 w30 vstate

Gui, Add, Text, xs right w70, Zip
Gui, Add, Edit, x+10 w60 vzip

Gui, Add, Button, x+10 h21 gAddName Default, Add to database

Gui, Add, ListView, xs y+20 r10 w700 AltSubmit vList1 -multi, Name|Address|City|State|Zip         ; to increase performance use count500 if you know the max number of lines

Gui, Add, StatusBar

Gui, Show,,MySQL Demo

;--------------------------------------
; fill listview will existing addresses from database
;-------------------------------------- 

Gosub, UpdateList1

return

;============================================================
; 
;============================================================ 

UpdateList1:

    Gui, Submit, NoHide      ; update control variables
    
    sql = 
    (    
         select name as Full_Name,
                address as Street,
                City,
                State,
                Zip
           from address
       order by name 
    )
    
    ; it is recommended to use underscores in alias names instead of quoted spaces so that the column can be referred to by aliasname potential having clause
    ; mysql.lvfill will remove underscores from aliasname before displaying as column headers
    
    result := mysql.query(db, sql)
    
    mysql.lvfill(sql, result, "List1")  

    ;LV_ModifyCol(2, 95)     ; limit width of a lengthy column
    
return

;============================================================
; Edit gui and insert request to table
;============================================================

AddName:
    
    gui, submit, nohide
    
    name := mysql.escape_string(name)   ; escape mysql special characters in case user entered them
    address := mysql.escape_string(address)   ; escape mysql special characters in case user entered them
    state := mysql.escape_string(state)   ; escape mysql special characters in case user entered them
    zip := mysql.escape_string(zip)   ; escape mysql special characters in case user entered them
    
    ;------------------------------------------------
    ; insert new request on table
    ;------------------------------------------------    

    SB_SetText("Inserting new request")
    
    sql = 
(
        INSERT INTO address (
            name,
            address,
            city,
            state,
            zip)
        VALUES (
            '%name%',
            '%address%',
            '%city%',
            '%state%',
            '%zip%')
)

    result := mysql.query(db, sql)
    
    newid := mysql.query(db, "SELECT LAST_INSERT_ID()")
    
    Gosub, UpdateList1  
    
    gui, submit, nohide    ; IMPORTANT
    
return

;============================================================
; when you click x or close button
;============================================================ 

GuiClose:
        
ExitApp