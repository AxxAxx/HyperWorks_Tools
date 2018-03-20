
namespace eval createGeomFromBar {
	##############################################################################
	#  Performance Routine
	##############################################################################
	proc Performance {flag} {
	   switch $flag {
	      "on" {
	         #/puts "Performance is on"
	         *retainmarkselections 0
	         *entityhighlighting 0
	         hm_blockredraw 1
	         hm_blockmessages 1
	         hm_commandfilestate 0
	         hwbrowsermanager view flush false
	      }
	      "off" -
	      default {
	         #/puts "Performance is off"
	         *retainmarkselections 1
	         *entityhighlighting 1
	         hm_blockredraw 0
	         hm_blockmessages 0
	         hm_commandfilestate 1
	         hwbrowsermanager view flush true
	      }
	   }
	}
	##############################################################################

	proc main {} {

		#*createentity comps name= new_geom
		#*currentcollector comps "new_geom"
		Performance off
		*createmarkpanel elems 1 " Select Bar elems"

		set cL [hm_getmark elems 1]
		#set meshsize [hm_getfloat "Mesh size=" "Please specify a mesh size"]
		#eval *createmark elems 1 "by comp" $cL
		#set selElem [hm_marklength elems 1]

		#*createmark elems 2 "by config" bar2
		#*markintersection elems 1 elems 2
		#set validElem [hm_marklength elems 1]

		#if {$selElem != $validElem } {
		#	tk_messageBox -message "Some elements are not beams"
	    #} else {
			Performance on

			foreach c $cL {
				#set ccN [hm_getentityvalue comps $c name 1 -byid]
				#*currentcollector comps $ccN
				
				set cP [hm_getentityvalue elems $c propertyid 0 -byid]


				*createmark elems 1 "by id" $c
				set ceL [hm_getmark elems 1]
				set dim1 [hm_attributevalue props $cP [hm_attributeidfromname "pbeamlDIM1A"] -byid]
				set dim2 $dim1
				#puts "dim1 $dim1"
				#puts "dim2 $dim2"
				set cnList {}
				
				if {$dim1 !=0} {
					foreach e $ceL {
						set cenL [hm_nodelist $e]
						set n1 [lindex $cenL 0]
						set n2 [lindex $cenL 1]

						lappend cnList $n1 $n2
						
						set distV [hm_getdistance nodes $n1 $n2 0]
						set len [lindex $distV 0]

						set base_x [lindex [hm_nodevalue $n1] 0]
						set base_y [lindex [hm_nodevalue $n1] 1]
						set base_z [lindex [hm_nodevalue $n1] 2]

						set mvec_x  	[lindex $distV 1]
						set mvec_y 	[lindex $distV 2]
						set mvec_z 	[lindex $distV 3]

						lassign $distV dummy x y z
						if {[expr abs($x)-abs($y)]>0} {
						  #x ist nicht Null
						  set nvec [list $y [expr -$x] 0]
						} elseif {[expr abs($z)-abs($y)]>0} {
						  #z ist nicht Null
						  set nvec [list 0 [expr -$z] $y]
						} else {
						  #y ist der groesste Wert
						   set nvec [list [expr -$y] $x 0]
						}

						set nvec_x [lindex $nvec 0]
						set nvec_y [lindex $nvec 1]
						set nvec_z [lindex $nvec 2]

						*surfacespherefull $n1 [expr $len*0.315]
						*surfacespherefull $n2 [expr $len*0.315]
						*surfacemode 4
						*surfaceconefull $n1 $n2 $dim1 $dim2 1 $len
						
					}
				#*createmark surfaces 1 "by comp" $c
				#*rbody_mesh 1 [expr $len/100] [expr $len*10] 0.1 5 1 0 1 1 2 
				#*createmark components 1 $c
				#*equivalence components 1 0.01 1 0 0 

				}
			}

			#*createentity comps name=BoundingBlock
			#*solidblock 0 0 0 10000 0 0 0 10000 0 0 0 10000 

			Performance off
			*clearmarkall 1
			*clearmarkall 2

		}
	#}
}
 
createGeomFromBar::main

