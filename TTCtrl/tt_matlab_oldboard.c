/*
 * matlab interface library
 */
#include <stdlib.h>
#include <stdio.h>
#include "engine.h"
#include "tt_matlab.h"
#define  BUFSIZE 256

// Define this symbol to enable open-loop control of the camera lens
// (ignoring feedback from the strain gauges)
// as detailed in Mario's email
#undef OPENLOOP

#ifdef OPENLOOP
char dir[] = "/home/aosup/hvc_mario_v1.01_openloop";
#else
char dir[] = "/home/aosup/hvc_mario_v1.01";
#endif

char buffer[BUFSIZE];

Engine *eep = NULL;

void *matlab_init()
{

	if (eep) {
		engClose(eep);
		eep=NULL;
	}
	/*
	 * Start the MATLAB engine locally by executing the string
	 * "matlab"
	 *
	 * To start the session on a remote host, use the name of
	 * the host as the string rather than \0
	 *
	 * For more complicated cases, use any string with whitespace,
	 * and that string will be executed literally to start MATLAB
	 */
	if (!(eep = engOpen("\0"))) {
		fprintf(stderr, "\nCan't start MATLAB engine\n");
		return (void *)EXIT_FAILURE;
	}

	/*
         * Initialize mirror
	 */
        matlab_cmd( eep, "cd '%s'", dir);
        matlab_cmd( eep, "init");
        matlab_cmd( eep, "mirrorSetAll");

        return (void *)eep;
}

void matlab_setTT( void *p, double x, double y) {

   Engine *ep = (Engine *)p;
   if (!ep)
       return;

   double min=-3e-3;
   double max=3e-3;

   if (x<min)
       x=min;
   if (y<min)
       y=min;
   if (x>max)
       x=max;
   if (y>max)
       y=max;

   matlab_cmd( ep, "aoWrite('hvc_TT1_bias_command',[%g %g 0 0],0:3);", x, y); 
}

void matlab_setMod( void *p, double freq, double amp) {

   Engine *ep = (Engine *)p;
   if (!ep)
       return;

   double minamp=0;
   double maxamp=0.5e-3;
   double minfreq=0;
   double maxfreq=1000;

   if (amp<minamp)
       amp=minamp;
   if (freq<minfreq)
       freq=minfreq;
   if (amp>maxamp)
       amp=maxamp;
   if (freq>maxfreq)
       freq=maxfreq;

   // Double check amplitude
   double maxProduct = 170* 1e-3;
   if (amp*freq > maxProduct) {
      amp = maxProduct / freq;
   }

   matlab_cmd( ep, "stopTimeHistory");
   matlab_cmd( ep, "modulation_Hz = %g", freq);
   matlab_cmd( ep, "modulation_Rad = %g", amp);
   matlab_cmd( ep, "startTimeHistory");
}

void matlab_cmd( void *p, char *fmt, ...) {

   Engine *ep = (Engine *)p;
   if (!ep) {
       printf("Matlab engine not initialized!\n");
       return;
   }

   va_list argList;
   vsprintf( buffer, fmt, argList);
   printf("%s\n", buffer);
   engEvalString(ep, buffer);
}



void matlab_setCL( void *p, double x, double y) {

   Engine *ep = (Engine *)p;
   if (!ep)
       return;

   double min=-60e-6;
   double max=60e-6;

   if (x<min)
       x=min;
   if (y<min)
       y=min;
   if (x>max)
       x=max;
   if (y>max)
       y=max;


#ifdef OPENLOOP
   // Open loop control (curr_command) 
    matlab_cmd( ep, "aoWrite('hvc_TT2_curr_command',[%g %g 0 0],0:3);", x, y);
#else
   // Closed loop control (bias_command)
   matlab_cmd( ep, "aoWrite('hvc_TT2_bias_command',[%g %g 0 0],0:3);", x, y);
#endif

}

void matlab_rip( void *p) {

    Engine *ep = (Engine *)p;
   if (!ep)
       return;

    matlab_cmd( ep, "mirrorRip");
}
