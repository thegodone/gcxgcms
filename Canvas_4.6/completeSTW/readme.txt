This MATLAB package uses Semi-parametric Time Warping (STW) to align chromatograms. The main script is completeSTWwarp.m, in which the following user input is necessary: 

1. A reference chromatogram
2. Chromatogram(s) to be aligned directly to the reference chromatogram 
3. Chromatogram(s) to be aligned by applying a warping function calculated from another chromatogram. In this case, only one signal should be loaded in step 2.
4. An alignment window in which the alignment should occur. This is a 1x2 matrix, in which the first entry is the start of the window and the second entry the end of the window, both given in retention times. If both are 0, the window is taken to be the entirety of the reference signal. The alignment window is applied after interpolating all other signals to match the reference signal.

All input chromatograms should be .mat files with the TIC in a variable called 'TIC' and the time axis in a variable called 'axis_min'.


Alignment algorithm:

The alignment algorithm used here is Semi-parametric Time Warping (STW), a variation on Parametric Time Warping (PTW) that uses B-splines as basis functions to compute the warping function (see Nederkassel et al., 2006). 


Smoothing:

The amount of smoothing performed on the signals before calculating the warping function is key to a successful alignment. After smoothing, peaks should be as smooth and broad as possible while still distinct. The variability in the optimal smoothing parameter has been taken into account by comparing the alignment quality for the most common range of smoothing parameter values. If the alignment is not visibly accurate, however, an adjustment of the smoothing parameter may be necessary.


MATLAB version:

The self-written MATLAB code was written with MATLAB version 7.10.0.499 (R2010a).



Acknowledgements:

- uipickfiles code was used unchanged from the MATLAB File Exchange, author Douglas M. Schwarz (2012).
- bspline_chrom code was used unchanged from the Eilers and Marx paper(1996). Only comments were added.
- difsm.m and difsmw.m were used unchanged from Eilers (2002)
- asysm.m came from Eilers (2002) but was edited to allow processing of multiple sequences and to include a later update to the algorithm written in R by Jan Gerretzen, Paul Eilers, Hans Wouters, Tom Bloemberg, Ron Wehrens and The R Development Core Team, 2014,
- interpol.m code was used unchanged from Eilers (2002). Only comments were added.
- semiparwarp is based on code for the PTW algorithm by Eilers (2002) and the STW algorithm described by Nederkassel et al. (2006). 



Literature:

Daszykowski, M.; Vander Heyden, Y.; Walczak B. Automated alignment of one-dimensional chromatographic fingerprints. Journal of Chromatography A. 1217 (2010) 6127-6133. 

Eilers, Paul H. C.; Marx, Brian D. Flexible smoothing with B-splines and penalties. Statist. Sci. 11 (1996), no. 2, 89-121.

Eilers, Paul H. C. Parametric Time Warping. Anal. Chem. 76 (2004), 404-411.

Nederkassel, A. M.; Daszykowski, M.; Eilers, P. H. C.; Vander Heyden, Y. A comparison of three algorithms for chromatograms alignment. Journal of Chromatography A, 1118 (2006) 199-210. 


