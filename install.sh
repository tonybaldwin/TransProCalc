#!/bin/bash

#####################################
# log in as root and execute this script to install transprocalc
# it will move the main transprocalc script, the calendar module, and the calculator
# to /usr/local/bin, and chmod (change permission) so they are all executable
# this is Free Software, according to the GPL, a copy of which is attached.
# by tony baldwin / www.tonybaldwin.me
####################################

name=$(whoami)

if [ $name != "root" ]; then
echo "You must be root or sudo to continue installation"
echo "Please log in as root or sudo and try again."

else

echo "Installing TransProCalc"
echo "configuring permissions"
chmod a+x tpcalc.tcl
chmod a+x tpcalendar
chmod a+x tcalcu
echo "Moving files"
cp tpcalc.tcl /usr/local/bin/tpcalc
cp tpcalendar /usr/local/bin/tpcalendar
cp tcalcu /usr/local/bin/tcalcu
cp tpcbnr1.gif /usr/share/

echo "Installation complete!"
echo "Thank you for using TransProCalc"
echo "To run TransProCalc, in terminal type tpcalc, or make an icon/menu item/short cut to /usr/local/bin/tpcalc"
echo "Enjoy!"

tpcalc &

fi
exit
###################
# this software is Free Software
# there is a copy of the Gnu Public License with this software
# this software is published according to said license
