

/***************************** Include Files *******************************/
#include "DDC_2.h"

/************************** Function Definitions ***************************/


void  radioTuner_setAdcFreq(u32 BaseAddress, float freq){
  u32 phase = calculate_phase(freq);
  DDC_mWriteReg(BaseAddress, ADC_PINC_OFFSET, phase);
}

void radioTuner_tuneRadio(u32 BaseAddress, float tune_frequency){
  u32 phase = calculate_phase(tune_frequency);
  DDC_mWriteReg(BaseAddress, TUNER_PINC_OFFSET, -1 * phase);
}

void  radioTuner_controlReset(u32 BaseAddress, u8 resetval){
  DDC_mWriteReg(BaseAddress, RST_OFFSET, resetval);

} // 1 = reset
u32 calculate_phase(float frequency){
	char bit_width = 27;
	float phase_incr = frequency*1.073741824;
	uint32_t phase_incr_int = phase_incr;
	return (u32) phase_incr_int;
}
