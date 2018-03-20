proc ::post::LoadSettings { legend_handle } { 
 $legend_handle SetType user 
 $legend_handle SetFilter Linear
 $legend_handle SetPosition upperleft
 $legend_handle SetNumericFormat "scientific"
 $legend_handle SetNumericPrecision "3"
 $legend_handle SetReverseEnable false
 $legend_handle SetSeparatorWidth 0
 $legend_handle SetNumberOfColors 9 
 $legend_handle SetColor 0 "  0   0 200" 
 $legend_handle SetColor 1 " 21 121 255" 
 $legend_handle SetColor 2 "  0 199 221" 
 $legend_handle SetColor 3 " 40 255 185" 
 $legend_handle SetColor 4 " 57 255   0" 
 $legend_handle SetColor 5 "170 255   0" 
 $legend_handle SetColor 6 "255 227   0" 
 $legend_handle SetColor 7 "255 113   0" 
 $legend_handle SetColor 8 "255   0   0" 
 $legend_handle SetColor 9 "192 192 192" 
 $legend_handle GetHeaderAttributeHandle attr_handle 
 attr_handle SetVisibility false
 catch { attr_handle SetFont "Arial"};
 attr_handle SetHeight 10
 attr_handle SetColor "255 255 255" 
 attr_handle SetSlant "regular" 
 attr_handle SetWeight "regular" 
 attr_handle ReleaseHandle 
 $legend_handle GetTitleAttributeHandle attr_handle 
 attr_handle SetVisibility true
 catch { attr_handle SetFont "Arial"};
 attr_handle SetHeight 12
 attr_handle SetColor "255 255 255" 
 attr_handle SetSlant "regular" 
 attr_handle SetWeight "bold" 
 attr_handle ReleaseHandle 
 $legend_handle GetNumberAttributeHandle attr_handle 
 catch { attr_handle SetFont "Arial"};
 attr_handle SetHeight 12
 attr_handle SetColor "255 255 255" 
 attr_handle SetSlant "regular" 
 attr_handle SetWeight "bold" 
 attr_handle ReleaseHandle 
 $legend_handle SetMinMaxVisibility true max
 $legend_handle SetMinMaxVisibility true min
 $legend_handle SetMinMaxVisibility false max_local
 $legend_handle SetMinMaxVisibility false min_local
 $legend_handle SetMinMaxVisibility false entity
 $legend_handle SetMinMaxVisibility false bymodel
 $legend_handle SetTransparency true 
 $legend_handle SetBackgroundColor " 44  85 126" 
 $legend_handle GetFooterAttributeHandle attr_handle 
 attr_handle SetVisibility false
 catch { attr_handle SetFont "Arial"};
 attr_handle SetHeight 10
 attr_handle SetColor "255 255 255" 
 attr_handle SetSlant "regular" 
 attr_handle SetWeight "regular" 
 attr_handle ReleaseHandle 
 } 
