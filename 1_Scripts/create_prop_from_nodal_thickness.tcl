#Create an optistruct property card for each nodal thickness.

namespace eval createProp {}

proc createProp::createcard {compList} {
	#For each component, find nodal thickness.
	foreach comp $compList {
		set thickness [createProp::findThickness $comp]
		set thickness [expr $thickness / 1000]
		set compName [hm_getcollectorname comps $comp]
		#Need to check if the user profile is OPTISTRUCT... not done now
		*createentity props cardimage=PSHELL name=$compName
		puts "thickness=$thickness"
		set propId [hm_entitymaxid props]
		*setvalue props id=$propId STATUS=1 95=$thickness
		*setvalue comps id=$comp propertyid={props $propId}
	}
}

proc createProp::findThickness {comp} {
		#for each component, query an element and find its nodal thickness.
		*createmark nodes 1 "by component id" $comp
		set n1 [lindex [hm_getmark nodes 1] 0]
		set n2 [lindex [hm_getmark nodes 1] 1]
		set n3 [lindex [hm_getmark nodes 1] 2]
		puts "n1=$n1 n2=$n2 n3=$n3"
		set t1 [hm_getnodalthickness nodes $n1]
		set t2 [hm_getnodalthickness nodes $n2]
		set t3 [hm_getnodalthickness nodes $n3]
		puts "t1=$t1 t2=$t2 t3=$t3"

		return [expr ($t1+$t2+$t3)/3]
}

*createmarkpanel comps 1 "Select batchmeshed components to create properties on..."
set compList [hm_getmark comps 1]
if {[hm_getmark comps 1] eq ""} {return}

createProp::createcard $compList

*clearmark comps 1


