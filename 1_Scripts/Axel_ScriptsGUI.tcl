package require hwt;

namespace eval ::MyNameSpace::UI {
variable m_base
variable m_master_frame
}
#########################################################
proc ::MyNameSpace::UI::CreateActionFrame { } {
#Action Frame
set action_frame [frame $::MyNameSpace::UI::m_master_frame.action_frame -height 100 -width 100];
pack $action_frame -side top -anchor nw;

button $action_frame.pos20 -text "Rotate 20 deg Positive" -borderwidth 3 -width 20 -command "::MyNameSpace::UI::Pos20"
button $action_frame.neg20 -text "Rotate 20 deg Negative" -borderwidth 3 -width 20 -command "::MyNameSpace::UI::Neg20"
button $action_frame.pos10 -text "Rotate 10 deg Positive" -borderwidth 3 -width 20 -command "::MyNameSpace::UI::Pos10"
button $action_frame.neg10 -text "Rotate 10 deg Negative" -borderwidth 3 -width 20 -command "::MyNameSpace::UI::Neg10"

button $action_frame.bolt_btn -text "Show/Export Bolt Model" -borderwidth 3 -width 20 -command "::MyNameSpace::UI::Bolt"
button $action_frame.nobolt_btn -text "Show/Export Moment-beam Model" -borderwidth 3 -width 30 -command "::MyNameSpace::UI::NoBolt"

pack $action_frame.pos20 -side top -fill both -padx [list 0 0] -pady 2 -in $action_frame
pack $action_frame.neg20 -side top -fill both -padx [list 0 0] -pady [list 2 20] -in $action_frame
pack $action_frame.pos10 -side top -fill both -padx [list 0 0] -pady 2 -in $action_frame
pack $action_frame.neg10 -side top -fill both -padx [list 0 0] -pady [list 2 20] -in $action_frame
pack $action_frame.bolt_btn -side top -fill both -padx [list 0 0] -pady 2 -in $action_frame
pack $action_frame.nobolt_btn -side top -fill both -padx [list 0 0] -pady 2 -in $action_frame

button $action_frame.cancel_btn -text "CANCEL" -borderwidth 3 -width 10 -command "::MyNameSpace::UI::OnCancel"
pack $action_frame.cancel_btn -side right -padx [list 0 0] -pady 10 -in $action_frame


}

#########################################################

proc ::MyNameSpace::UI::DestroyDialog { } {
if {[info exists ::MyNameSpace::UI::m_base]} {
    destroy $::MyNameSpace::UI::m_base
}
}

#########################################################

proc ::MyNameSpace::UI::Neg20 { } {
*drawlistresetstyle 
*createmark elements 1 "all"
*createplane 1 0 1 0 0 0 0
*rotatemark elements 1 1 -20
}

proc ::MyNameSpace::UI::Pos20 { } {
*drawlistresetstyle 
*createmark elements 1 "all"
*createplane 1 0 1 0 0 0 0
*rotatemark elements 1 1 20
}


proc ::MyNameSpace::UI::Neg10 { } {
*drawlistresetstyle 
*createmark elements 1 "all"
*createplane 1 0 1 0 0 0 0
*rotatemark elements 1 1 -10
}

proc ::MyNameSpace::UI::Pos10 { } {
*drawlistresetstyle 
*createmark elements 1 "all"
*createplane 1 0 1 0 0 0 0
*rotatemark elements 1 1 10
}

proc ::MyNameSpace::UI::Bolt { } {
*entitysuppressactive components 1 0
*entitysuppressoutput components 1 0
*entitysuppressactive components 2 1
*entitysuppressoutput components 2 1
}

proc ::MyNameSpace::UI::NoBolt { } {
*entitysuppressactive components 1 1
*entitysuppressoutput components 1 1
*entitysuppressactive components 2 0
*entitysuppressoutput components 2 0
}

#########################################################

proc ::MyNameSpace::UI::OnCancel { } {
::MyNameSpace::UI::DestroyDialog
}

#########################################################

proc ::MyNameSpace::UI::Main { } {
if {[info exists ::MyNameSpace::UI::m_base]} {
    destroy $::MyNameSpace::UI::m_base
}
#Set value for m_base
set ::MyNameSpace::UI::m_base .bjaDialog
toplevel $::MyNameSpace::UI::m_base
#Dialog title
wm title $::MyNameSpace::UI::m_base "My Script"
wm resizable $::MyNameSpace::UI::m_base 0 0
#Create Master Frame in Base
set ::MyNameSpace::UI::m_master_frame [frame $::MyNameSpace::UI::m_base.m_master_frame];
pack $::MyNameSpace::UI::m_master_frame -side top -anchor nw -padx 7 -pady 7 -expand 1 -fill both;
#Create Action Frame and add to Master Frame
::MyNameSpace::UI::CreateActionFrame
}

#########################################################

#Call Main
::MyNameSpace::UI::Main;