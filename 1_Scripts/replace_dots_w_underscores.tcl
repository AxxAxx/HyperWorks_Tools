# HWVERSION_2017.2_Jul 25 2017_19:31:43
#################################################
# This macro will simply remove the period from
# comp names so that ABAQUS does not choke on them
#################################################
source [file join [hm_info -appinfo SPECIFIEDPATH hw_tcl_common] "hw" "collector" "hwcollector.tcl"]

namespace eval ::AbaqusUtility:: {
    array unset Replace_gui;
	array unset renamed_entity;
    variable entity_type;
    variable found_types;
    variable Rep_entry;
    variable entity_type;
    variable reject_flag;
    set entity_type "ALL";
    set reject_flag 0;
	set ::AbaqusUtility::entities "";
}
############################################################################################################
#Repalce Any string with any string function

proc ::AbaqusUtility::Replace_dot_entity {entity} {
    variable Rep_entry;
    variable Repwit_entry;
    variable Replace_gui;
    variable reject_flag;
	variable entity_type;
	variable renamed_entity;
    set name_list {};
    set ::AbaqusUtility::rep_wat "";
    set ::AbaqusUtility::rep_wit "";
    set ::AbaqusUtility::rep_wat [$Rep_entry get];
    set ::AbaqusUtility::rep_wit [$Repwit_entry get];
	*clearmark $entity 1;
	*createmark $entity 1 all;
	
	if {![hm_marklength $entity 1]} {
        return;
    }
	set name_list [hm_getvalue $entity mark=1 dataname=name]	
    if {$::AbaqusUtility::rep_wat != ""} {
		if {$::AbaqusUtility::entities != ""} {
			foreach entityid $::AbaqusUtility::entities {
				set entityName [string map {"\"" "\\\""} [hm_getcollectorname $entity $entityid]]
				set newName [string map "\"$::AbaqusUtility::rep_wat\" \"$::AbaqusUtility::rep_wit\"" "$entityName"]
				if {![llength $newName]} {
					$Replace_gui(dialog) statusmessage "Cannot Replace the Entity: $entityName   "
					continue;
				}
				if {![string match $entityName $newName] && [lsearch $name_list $newName] == -1  } {
					if {$entity != "titles"} {
						catch { *renamecollector $entity $entityName $newName} result
						if {!$result} {
							lappend renamed_entity($entity) [list "$newName" "$entityName"]
						}
					}
				}
			}
		} else {
			foreach entityName $name_list {
				set newName [string map "\"$::AbaqusUtility::rep_wat\" \"$::AbaqusUtility::rep_wit\"" "$entityName"]
				if {![llength $newName]} {
					$Replace_gui(dialog) statusmessage "Cannot Replace the Entity: $entityName   "
					continue;
				}
				if {![string match $entityName $newName] && [lsearch $name_list $newName] == -1} {
					if {$entity != "titles"} {
						catch { *renamecollector $entity $entityName $newName} result
						if {!$result} {
							lappend renamed_entity($entity) [list "$newName" "$entityName"]
						}
					}
				}
			}
		}
	} 
	*clearmark $entity 1;
}

############################################################################################################
proc ::AbaqusUtility::HighLight {flag} {
    
    switch $flag {
        "off" {
            *retainmarkselections 0;
            *entityhighlighting 0;
            hm_blockmessages 1;
        }
        "on" -
        default {
            *retainmarkselections 1;
            *entityhighlighting 1;
            hm_blockmessages 0;
        }
    }
    
}

#############################################################################################################
proc ::AbaqusUtility::Replace_fun args {
    variable entity_type;
    variable found_types;
	variable renamed_entity;
	variable Replace_gui;
	
    if {$entity_type == "ALL"} {
        set found_types [lremove $found_types "ALL"]
        set entity_type $found_types
    }
	array unset renamed_entity;
	$Replace_gui(dialog) statusmessage "";
    foreach entity $entity_type {
        ::AbaqusUtility::Replace_dot_entity $entity;
    }
    ::AbaqusUtility::HighLight on;
}

############################################################################################################
#Funct to get all the named entity in the model
proc ::AbaqusUtility::GetEntityTypes args {
    variable found_types;
    variable Replace_gui;
    #Get the list of named entity TYPES that exist in a model
    set named_entitytypes "";
    set named_entitytypes [hm_getentitytypes named]
    set found_types "ALL"
    foreach named_entitytype $named_entitytypes {
        if {[hm_entitylist $named_entitytype id] != ""} {
            lappend found_types $named_entitytype
        }
    }
    return $found_types
}

###############################################################################################################
#Dialog creation function
proc ::AbaqusUtility::Replace_dialog args {
    variable Replace_gui;
    variable Rep_entry;
    variable Repwit_entry;
	set ::AbaqusUtility::replace_with ""
    
    if {[winfo exists .dlgreplace] } {
        destroy .dlgreplace
    }
    set Replace_gui(dialog) [::hwtk::dialog .dlgreplace -title "Find and Replace" -x 600 -y 300 -minheight 150  -modality hyperworks  \
            -minwidth 200;]
    
    set Recess_frame [$Replace_gui(dialog) recess]
    
    set mainframe [::hwtk::frame $Recess_frame.main]
    grid configure $mainframe -sticky ew;
    
    set Rep_label [::hwtk::label $mainframe.lbl1 -text "Replace What:" ]
    set Rep_entry [::hwtk::entry $mainframe.ent1 -textvariable ::AbaqusUtility::replace_wat]
	$Rep_entry configure -validate all -validatecommand "::AbaqusUtility::ValidateRep_with %S"
    
    grid configure $Rep_label $Rep_entry -sticky w
    grid configure $Rep_entry -sticky ew
    
    set Repwit_label [::hwtk::label $mainframe.lbl2 -text "Replace With:" ]
    set Repwit_entry [::hwtk::entry $mainframe.ent2  -textvariable ::AbaqusUtility::replace_with ]
    $Repwit_entry configure -validate all -validatecommand "::AbaqusUtility::ValidateRep_with %S"
    
    grid $Repwit_label $Repwit_entry -sticky w 
    grid configure $Repwit_entry -sticky ew
    
    
    #set collector_frame [::hwtk::frame $Recess_frame.cltr ]
    #pack $collector_frame -side top -anchor nw
    
    set SelectEntityType [::hwtk::label $mainframe.lbl3 -text "Entity Type:" ]
    #pack $SelectEntityType -side left -anchor nw -pady 2 -padx 2
    
    set entitytypes [::AbaqusUtility::GetEntityTypes]
    set Entity [ Collector $mainframe.components entity 1 HmMarkCol \
            -types $entitytypes \
            -withtype 1 \
            -withReset 1 \
            -callback [namespace current]::Select_entity]
    #pack $collector_frame.components -side left -anchor nw -padx 4 -pady 4;
    grid $SelectEntityType $mainframe.components  -sticky w 
    grid configure $mainframe.components -sticky news
    
    grid configure {*}[grid slaves $Recess_frame] -padx 5 -pady 5
	grid columnconfigure $Recess_frame 0 -weight 1
	grid configure {*}[grid slaves $mainframe] -padx 5 -pady 5
	grid columnconfigure $mainframe 1 -weight 1
	
    $Replace_gui(dialog) buttonconfigure ok -text "Replace"
    $Replace_gui(dialog) buttonconfigure ok -command ::AbaqusUtility::Replace_fun
    $Replace_gui(dialog) hide apply 
    $Replace_gui(dialog) post;
}

############################################################################################################################
#Collector

proc ::AbaqusUtility::Select_entity args {
    variable Replace_gui;
    variable entity_type;
	variable Replace_gui;
    set entity_type [lindex $args 3]
	set ::AbaqusUtility::entities "";
    switch -- [lindex $args 0] {
		"getadvselmethods" {
			wm withdraw $Replace_gui(dialog);
			set entity_type [lindex $args 1]
			hm_markclear $entity_type 1
			*createmarkpanel $entity_type 1 "SelectEntityType"
			if { [hm_marklength $entity_type 1] ne 0 } { 
			  set ::AbaqusUtility::entities [hm_getmark $entity_type 1]
			}
			hm_markclear $entity_type 1
			wm deiconify $Replace_gui(dialog);
		}
		"reset" {
			set ::AbaqusUtility::entities  "";
		}
		default {
			return 0;
		}
	}
}

###############################################################################################################################
#Undo the Replace action -Only one step

proc ::AbaqusUtility::Reject args {
    variable entity_type;
    variable Replace_gui;
    variable reject_flag;
	variable renamed_entity;
    
    set entity_type [array names renamed_entity];
	foreach type $entity_type {
		*clearmark $type 1;
		*createmark $type 1 all;
		set name_list [hm_getvalue $type mark=1 dataname=name]
		set entities $::AbaqusUtility::renamed_entity($type)
		foreach e1 $entities {
			set newName [lindex $e1 1]
			set entityName [lindex $e1 0]
			if {![string match $entityName $newName] && [lsearch $name_list $newName] == -1} {
				eval *renamecollector $type {[set entityName]} {[set newName]};
			}
		}
		
	}
    #$Replace_gui(dialog) buttonconfigure apply -state disabled
}

##############################################################################################################################
proc ::AbaqusUtility::ValidateRep_with {val} {
    variable Replace_gui;
    variable reject_flag;
    if {$val == ""} {
        #$Replace_gui(dialog) buttonconfigure apply -state disabled
        #set reject_flag 0;
        return 0;
    } elseif { [string match "$val" \"] == 1} {
		return 0;
	} else {
        return 1;
    }
}

######################################################

::AbaqusUtility::Replace_dialog;

#############################################################
