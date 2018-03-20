# #######################################################################
#
# Remove solid holes with arbitrary shape in displayed component
#
# #######################################################################
#
# Altair Engineering, Inc.  2012
#
# Author: Fredrik Nordgren, October 2012
#
# #######################################################################



set type "solids"

#set maxDiam 2.0
set maxDiam [hm_getfloat "Max diameter" "Enter max diameter"]

set crossSize 100.0


#options, 0 for arbitrary shaped
set opt 0


*createmark solids 1 displayed
*remove_solid_holes $type 1 $maxDiam $crossSize $opt 1 0