# HWVERSION_2017.2_Jul 25 2017_19:31:43
#########################
# Change log:
#########################
# User specified number of backups.
# Create a log file with date/time info.
# Provide option to enable/disable log file creation.
# Option for backup filename extension.
# Fix when autosave on/off is used with empty model.
#########################
namespace eval autosave {
    variable tint;
    variable numbackups;
    variable backupfilename;
    variable backupfileextn;
    variable backupnumber:
    # variable currhmfilename;
    variable isenabledlog;
    variable logfile;
    variable saveOn;
    variable jobIds;
    variable base;
}


proc ::autosave::CreateDialog { args } {
    variable base;
    set base .autosaveWindow
    if {[winfo exists $base]} {
            wm deiconify $base; return
    }
    
    variable tint;
    variable numbackups;
    variable backupfilename;
    variable backupfileextn;
    # variable currhmfilename;
    variable isenabledlog;
    variable logfile;
    variable jobIds;
    variable saveOn;
    
    set  ::autosave::numbackups "5"
    set  ::autosave::backupfileextn "hmbackup"
    set  ::autosave::tint "10";
    # set  ::autosave::currhmfilename "";
    set  ::autosave::afterid "";
    set  ::autosave::saveOn 1;
    # Logging is enabled by default
    set  ::autosave::isenabledlog 1;
    
    # window size in dialog units (dlu)
    set dlgWidth  [ hwt::DluWidth  225 [ hwt::AppFont ]];
    set dlgHeight [ hwt::DluWidth  125 [ hwt::AppFont ]];

    # create the dialog without any default buttons
    ::hwt::CreateWindow autosaveWindow \
        -windowtitle "Auto Save" \
        -geometry ${dlgWidth}x${dlgHeight} \
        -minsize $dlgWidth $dlgHeight \
        -noGeometrySaving \
        -cancelButton Cancel \
        -acceptButton {Auto Save} \
        -acceptFunc ::autosave::AutoSave \
        -cancelFunc ::autosave::cancel\
        -addButton "Clear Current Log" ::autosave::ClearLogFile no_icon \
        -defaultButton accept;
        
    # get the main frame in the window
    set recess [::hwt::WindowRecess autosaveWindow];
    set guiFrame [frame $recess.guiFrame];
    pack $guiFrame -anchor nw -side left -fill both -expand 1;
    
    set dirSelection [ hwt::AddEntry $guiFrame.entry2 \
                    Label "Backup Filename:" \
                    LabelWidth 20 \
                    entrywidth 100 \
                    ListProc whenPressed "autosave::dirBrowse $recess"\
                    iconName msfolder.gif \
                    iconLoc  -1 2 \
                    textvariable ::autosave::backupfilename ];
        
    hwt::AddPadding $guiFrame -side top -height [hwt::DluHeight 4]
    
    set timeInterval [ hwt::AddEntry $guiFrame.entry3 \
                        Label "Time Interval (minutes):" \
                        LabelWidth 20 \
                        entrywidth 100 \
                        validate    real \
                        textvariable ::autosave::tint ];
    
    hwt::AddPadding $guiFrame -side top -height [hwt::DluHeight 4]
    
    set numBackups [ hwt::AddEntry $guiFrame.entry0 \
                    Label "Number of Backups:" \
                    LabelWidth 20 \
                    entrywidth 100 \
                    validate    real \
                    textvariable ::autosave::numbackups ];

    hwt::AddPadding $guiFrame -side top -height [hwt::DluHeight 4]

    set numBackups [ hwt::AddEntry $guiFrame.entry1 \
                    Label "Backup File Extension:" \
                    LabelWidth 20 \
                    entrywidth 100 \
                    -justify right \
                    textvariable ::autosave::backupfileextn ];

    hwt::AddPadding $guiFrame -side top -height [hwt::DluHeight 4]

    checkbutton $guiFrame.checkbutton0 -text \
    "Enable Logging (hm_autosave.log)" \
    -variable ::autosave::isenabledlog 


    hwt::AddPadding $guiFrame -side top -height [hwt::DluHeight 4]
  
    pack $guiFrame.checkbutton0 -anchor nw -side left

 
  #  pack $dirSelection -side left
  #  set minLabel [label $guiFrame.label1 -text "minutes"]
    
  #  pack $minLabel -anchor nw -side top -pady 3 -padx 4
                    
    ::hwt::PostWindow autosaveWindow;
}

#-------------------------------------------------------
proc ::autosave::dirBrowse { args } {	
    set types {
       {{HM and HM backup files} {*.hm*} }
       {{All files} {*.*} }
    }

	set tmpfilename [ tk_getSaveFile -parent .autosaveWindow \
	-title "Specify Backup Filename" -filetypes $types -initialfile $::autosave::backupfilename];
	if {$tmpfilename != ""} {
	     set ::autosave::backupfilename $tmpfilename;
           }
	
}


proc ::autosave::AutoSave { args } {
    
    variable tint;
    variable numbackups;
    variable backupfilename;
    variable backupfileextn;
    variable backupnumber;
    # variable currhmfilename;
    variable isenabledlog;
    variable logfile;
    variable jobIds;
    variable saveOn;
    variable base;


    if {$numbackups == ""} {
       tk_messageBox -message "Number of backups not provided. Please provide\
       all necessary information." -icon warning \
       -type ok \
       -title "Insufficient information"
       return;
    } 

    if {$backupfileextn == ""} {
       tk_messageBox -message "Backup file extension not provided. Please\
       provide all necessary information." \
       -icon warning \
       -type ok \
       -title "Insufficient information"
       return;
    } 
    if {$backupfilename == ""} {
        tk_messageBox -message "Backup filename not provided. Please\
	provide all necessary information." -icon warning \
        -type ok \
        -title "Insufficient information"
        return;
    } 
    
    if {$tint == ""} {
        tk_messageBox -message "Time interval not provided.\
	Please provide all necessary information." -icon warning \
        -type ok \
        -title "Insufficient information"
        return;
    }

    if {$tint == 0} {
        tk_messageBox -message "Time interval cannot be zero." \
	-icon warning \
        -type ok \
        -title "Incorrect information"
        return;
    }

    if {$tint > 480} {
        tk_messageBox -message "Maximum allowed time interval is 480 minutes\
       	(8 hours)." \
	-icon warning \
        -type ok \
        -title "Incorrect information"
        return;
    }

    if {$numbackups > 99} {
        tk_messageBox -message "Maximum number of backups allowed is 99."\
	-icon warning \
        -type ok \
        -title "Incorrect information"
        return;
    }

    set ::autosave::jobIds [list] 

    ::hwt::UnpostWindow $base;

    ::autosave::SaveOnOff;
}

proc ::autosave::AutoSaveOn { args } {
    variable saveOn;
    set  ::autosave::saveOn 1;
    ::autosave::CreateDialog
}

proc ::autosave::AutoSaveOff { args } {
    variable saveOn;
    set ::autosave::saveOn 0;
    ::autosave::SaveOnOff;
    return;
}

proc ::autosave::cancel { args } {
    variable base;
    ::hwt::UnpostWindow $base;
    return;
}

proc ::autosave::SaveOnOff { args } {

    variable tint;
    variable numbackups;
    variable backupfilename;
    variable backupfileextn;
    variable backupnumber;
    # variable currhmfilename;
    variable isenabledlog;
    variable logfile;
    variable jobIds;
    variable saveOn;

    set ::autosave::backupnumber 1

    set after_command {

    if {$::autosave::isenabledlog == 1} {
    	set ::autosave::logfile [open "hm_autosave.log" "a"]

        if {([llength $::autosave::logfile]==0)} {

	tk_messageBox -icon warning -title "Altair HyperMesh" \
	-icon warning -type ok -message "Warning: Unable to open\
         log file. Disabling output to log file."

         set ::autosave::isenabledlog 0;
      }
    }
    set ::autosave::backupfilenametemp ""
    set extn $::autosave::backupfileextn;
    #set spltfilename [file rootname $::autosave::backupfilename] 
    #set ::autosave::backupfilename $spltfilename
    append ::autosave::backupfilenametemp $::autosave::backupfilename \
    "_$::autosave::backupnumber" "." $extn;
    hm_answernext yes;

    *writefile "$::autosave::backupfilenametemp" 1;
    incr ::autosave::backupnumber;

    if {$::autosave::backupnumber > $::autosave::numbackups} {
        set ::autosave::backupnumber 1};

    # If logging is enabled, insert file/date/time stamp.
     
    if {$::autosave::isenabledlog == 1} {

	    puts -nonewline $::autosave::logfile \
	    "*** File: [file tail $::autosave::backupfilenametemp]\
	    saved on [clock format [clock seconds] -format "%D %T"] ***\n"

    if {![Null ::autosave::logfile]} {
            close $::autosave::logfile;
    }
    }
}
    if {[info exists tint]} {
    set tIntLoc [expr ($tint * 60000)];
    }
    
    set tInteger [expr int($tIntLoc)]
   
    
    if  {  $::autosave::saveOn == 1 } {
	    
    tk_messageBox -title "Altair HyperMesh" -icon info -type ok\
    -message "AutoSave activated."

	    # Max 1 day of autosave (8 hours)
	    # 480 = 60 * 8 minutes

            set minutes_1day 480
	    # tint is still in minutes
	    set max_times  [expr $minutes_1day / $tint ]

	    for {set i 0} {$i < $max_times} {incr i} {
		    set time_ms [expr $tInteger * $i]
		    set afterid [after $time_ms $after_command]
		    if {[info exists jobIds]} {
	            lappend ::autosave::jobIds $afterid
	            }
                    #tk_messageBox -title "Altair HyperMesh" -message \
		    #"Adding job: $temp" -type ok -icon info
            } 
	    #tk_messageBox -message "Add:$::autosave::jobIds"

    } else {
                            tk_messageBox -title \
			    "Altair HyperMesh" \
			    -icon info -type ok\
                            -message "AutoSave de-activated."

			    if {[info exists jobIds]} {
			    foreach id $::autosave::jobIds {
			    after cancel $id
		            }
		            }
                            
	                    #tk_messageBox -message\
			    #"Cancel:$::autosave::jobIds"
	    }
            return;
}    

proc ::autosave::ClearLogFile { args } {

    variable logfile;
    
    # Open the log file in write mode to clear it 
    # of its current contents
    
    set ::autosave::logfile [open "hm_autosave.log" "w"]
    close $::autosave::logfile
    
    tk_messageBox -title "Altair HyperMesh" -message "Log cleared." \
    -icon info -type ok
    

    }
#::autosave::CreateDialog
