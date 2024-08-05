# OverPlot
MATLAB Utility to plot data over images

Simple GUI tool to plot X,Y data onto a 2D image plot. No plot skewness is
handled currently. Pass along X,Y or {X1,X2,X3},{Y1,Y2,Y3} data cell arrays.
No error catching is implemented at this point. Log plotting needs to be tested

Order of Operations:
1. Generate X-Y data which you wish to overlay
2. Call OverPlot(x,y)
3. Open image
4. Select control ploints
5. Toggle control points if desired 
6. Send to workspace or figure file for future reference

Remark:
Use as is, only tested with a simple test case at this time. 