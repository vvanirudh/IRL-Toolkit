Scalable Vector Graphics (SVG) Export of Figures

Converts 2D & 3D Matlab plots to the scalable vector format (SVG). This format is specified by W3C (http://www.w3.org) and can be viewed and printed with internet browsers.

Added preliminary support of filter, clipping, and tickmark extensions that go beyond the Matlab functionality. SVG filters are a great tool to create stylish plots! Try it out! Before you start using this new features have a look at the tutorial. More information and examples can be found on my webpage.
Tested browsers and editors for SVG filters:
  Opera 9.64,10.50  -> yes
  Firefox 3.5,3.6 -> yes
  Inkscape 0.46 -> yes (some limitations)
  IE + RENESIS -> no

Use plot2svg_depreciated if you face problems due to the additional features. The function plot2svg_depreciated was the plot2svg of the last release.

IMPORTANT: Use 'v6' graphics option for Matlab versions > R14! (see below)

Editors for the SVG file format can be found at http://www.inkscape.org.

Usage:
> plot2svg   % opens a file dialog to plot the active figure
    or
> plot2svg('myfile.svg', figure handle, pixelfiletype)
    
  pixelfiletype = 'png' (default), 'jpg'         

IMPORTANT: Firefox 1.5 may hang if too many linear shaded patches are used in the figure.

See http://www.juergschwizer.de to get more informations

Supported Features
- line, patch, contour, contourf, quiver, surf, ...
- markers
- image (saved as linked png pictures)
- grouping of elements
- alpha values for patches
- subplot
- colorbar
- legend
- zoom
- reverse axes
- controls are saved as png pictures
- log axis scaling
- axis scaling factors (10^x)
- labels that contain Latex commands are interpreted (with some limitations):
\alpha, \Alpha, \beta, \Beta, ... \infity, \pm, \approx
{\it.....} for italic text
{\bf.....} for bold text
^{...} for superscript
_{...} for subscript

How to use SVG files in HTML code
<object type="image/svg+xml" data="./mySVGfile.svg" width="140" height="100"></object>

Changes in Version 22-May-2005
- bugfix line color
- bugfix path of linked jpeg figures
- improved patch handling (interpolation and texture still missing, preliminary depth sorting)
- support of pcolor plots
- preliminary: surface plots are projected on the xy-plane (use 'rotate' command)

Changes in Version 12-Dec-2005
- bugfix viewBox
- improvement of the axis scaling (many thanks to Bill Denney)
- improvement handling of exponents for log-plots
- default pixel format png instead of jpeg (many thanks to Bill Denney)
- bugfix axindex
- bugfix cell array cells (many thanks to Bill Denney)
- improved handling of pixel images (many thanks to Bill Denney)
- to save original figure background use set(gcf,'InvertHardcopy','off')
- improved markers

Changes in Version 8-Jan-2006
- axes handling fully reworked (3D axes)
- rework of axes scaling (3D axes)
- clipping enabled (Use carefully, as all figure data is written to file -> may get large)
- minor grid lines are now supported for linear and log plots
- linear color interpolation on patches (The interploation needs to be emulated as SVG does not support a linear interpolation of colors between three points. This is done by combination of different patches with linear alpha gradients. See limitation for Firefox 1.5.)

Changes in Version 20-Jun-2009
- Bugfix '°','±','µ','²','³','¼''½','¾','©''®'
- Bugfix 'projection' in hggroup and hgtransform
- Added Octave functionality (thanks to Jakob Malm)
  Bugfixe cdatamapping (thanks to Tom)
  Bugfix image data writing (thanks to Tom)
  Patches includes now markers as well (needed for 'scatter'
  plots (thanks to Phil)
- Bugfix markers for Octave (thanks to Jakob Malm)
- Bugfix image scaling and orientation
  Bugfix correct backslash (thanks to Jason Merril)
- Improvment of image handling (still some remaining issues)
  Fix for -. line style (thanks to Ritesh Sood)

Changes in Version 28-Jun-2009
- Improved depth sorting for patches and surface
- Bugfix patches
- Bugfix 3D axis handling

Changes in Version 11-Jul-2009
- Support of FontWeight and FontAngle properties
- Improved markers (polygon instead of polyline for closed markers)
- Added character encoding entry to be fully SVG 1.1 conform

Changes in Version 13-Jul-2009
- Support of rectangle for 2D
- Added preliminary support for SVG filters
- Added preliminary support for clipping with pathes
- Added preliminary support for turning axis tickmarks

Changes in Version 18-Jul-2009
- Line style scaling with line width (will not match with png
  output)
- Small optimizations for the text base line
- Bugfix text rotation versus shift
- Added more SVG filters
- Added checks for filter strings

Changes in Version 21-Jul-2009
- Improved bounding box calculation for filters
- Bugfixes for text size / line distance
- Support of background box for text
- Correct bounding box for text objects

Changes in Version 06-Mar-2010
- Improved support of filters
- Experimental support of animations
- Argument checks for filters
- Rework of tex string handling
- 'sub' and 'super' workaround for Firefox and Inkscape
- Bugfix for log axes (missing minor grid for some special
  cases)
- Bugfix nomy line #1102 (thanks to Pooya Jannaty)
- Bugfix minor tickmarks for log axis scaling (thanks to
  Harke Pera)
- Added more lex symbols
- Automatic correction of illegal axis scalings by the user
  (thanks to Juergen)
- Renamed plot2svg_beta to plot2svg

Limitations:
- axis scaling factors for 3D axes
- plot object of Matlab R14 not supported (use 'v6' switch instead)
- 3D plot functionality limited (depth sorting, light)

Example of a SVG file is included to the zip file.

Reports of bugs highly welcome. 
