

proc generate {drv_handle} {
	xdefine_include_file $drv_handle "xparameters.h" "DDC_2" "NUM_INSTANCES" "DEVICE_ID"  "C_config_BASEADDR" "C_config_HIGHADDR"
}
