#!/bin/sh

###########################################
# TransProCalc by tony baldwin, www.tonybaldwin.me
############################################
# TransProCal program is a project data organization and management tool
# for translators, with tools to manage information regarding multiple
# document, multiple provider, multiple language projects, and, to
# help do the math at the end, to see just how rich you're getting (right)
# and generates Reports (useful for tracking and documenting the project,
# and, useful to hand the bookkeeper. My bookkeeper likes them.
# Now, just to tickle wish a bit.\
exec wish8.5 -f "$0" ${1+"$@"}

package require Tk
package require Ttk

global allvars
# list allvars 
set allvars [list d8dl aladaex adchx1 adchx1t adchx2 adchx2t totpun pv5 pv5tlang pv5svc ctexp5 pv5d1 p5twc pv5rate texp5 pv4 pv4tlang pv4svc ctexp4 pv4d1 p4twc pv4rate texp4 pv3 pv3tlang pv3svc ctexp3 pv3d1 p3twc pv3rate texp3 pv2 pv2tlang pv2svc ctexp2 pv2d1 p2twc pv2rate texp2 pv1 pv1tlang pv1svc ctexp1 pv1d1 p1twc pv1rate texp1 tpcost gross aladex allCharges aladch adex1t adex2t adex3t adex4t adex1 adex2 adex3 adex4 totpx dnote ttrans ttrev pptu tottus dcwd d1no d2no d3no d4no d5no d6no d7no d8no d1tl d2tl d3tl d4tl d5tl d6tl d7tl d8tl dwc1 dwc2 dwc3 dwc4 dwc5 dwc6 dwc7 dwc8 did1 did2 did3 did4 did5 did6 did7 did8 dud8 tglangs srclang nodx pnum cid begin invd utype wrds rate price income trate tax net invo curnc note note1 note2 totpdo idud8 dtpd allSux estim8 novar]




foreach var $::allvars {global $var}
foreach var $::allvars {set $var " "}

global filename
set filename " "


bind . <Escape>  {exit}
bind . <F1> {Reset}
bind . <Return> {calculate}

# first window, gives option to create a ProjectIn Report for recording details of a new project
# and ProjectOut, used for the financial data upon invoicing (my bookkeeper loves these)
# and ProjectAssign for recording the data upon assigning the new project
# and calculating projected expenses for providers, etc.


set date [clock format [clock seconds] -format "%m / %d / %Y"]

set w .
wm title .  "TransProCalc"
wm iconname . "TPC"

image  create  photo  tpcbnr -format GIF -file  /usr/share/tpcbnr1.gif

####################################################
# main menu
####################################################
frame .menub -bd 2

menu .menub.f -tearoff 0
.menub.f add command -label "Open Project" -command {openproject}
.menub.f add command -label "Save Project" -command {saveproject}
.menub.f add separator
.menub.f add command -label "QuickEstimate" -command {quicke}
.menub.f add command -label "Calendar" -command {exec tpcalendar &}
.menub.f add command -label "Calculator" -command {exec tcalcu &}
.menub.f add command -label "Clear All" -command {Reset} -accelerator F1
.menub.f add separator
.menub.f add command -label "Quit" -command {exit} -accelerator Esc
.menub.f add command -label "About" -command {About}

pack .menub -in . -fill x

#######################################################
# menu bar main frame
#######################################################

frame .tpc1 -bd 2
grid [ttk::label .tpc1.tpc -image tpcbnr]\
[ttk::menubutton .tpc1.men -text "TransProCalc Menu" -menu .menub.f]\
[ttk::label .tpc1.labl -text "Today's date: $date"]
pack .tpc1 -in . -fill x

#######################################################
# end main menu - menu bar
#######################################################
# start frame to contain tabs
#######################################################

ttk::frame .f
pack .f -fill both -expand 1
set w .f
#######################################################
## Make the notebook and set up Ctrl+Tab traversal
#######################################################

ttk::notebook $w.note
pack $w.note -fill both -expand 1 -padx 2 -pady 3
ttk::notebook::enableTraversal $w.note


#######################################################
#  First tab - project documents 
#######################################################
ttk::frame $w.note.pdox
$w.note add $w.note.pdox -text "Project Docs" -underline 0

frame $w.note.pdox.t2c -bd 2
grid [ttk::label $w.note.pdox.t2c.labl -text "TransProCalc - Project Documents"]
grid [ttk::label $w.note.pdox.t2c.d8e -textvariable date]

pack $w.note.pdox.t2c -in $w.note.pdox -fill x

frame $w.note.pdox.pjdat -bd 5
# project nfo
grid [ttk::label $w.note.pdox.pjdat.prons -text "Project no.:"]\
[ttk::entry $w.note.pdox.pjdat.prno -textvariable pnum]\
[ttk::label $w.note.pdox.pjdat.cli -text "Client id:"]\
[ttk::entry $w.note.pdox.pjdat.clnt -textvariable cid]\
[ttk::label $w.note.pdox.pjdat.sdate -text "Start date:"]\
[ttk::entry $w.note.pdox.pjdat.sd -textvariable begin]

grid [ttk::label $w.note.pdox.pjdat.srcl -text "Src Lang:"]\
[ttk::entry $w.note.pdox.pjdat.slang -textvariable srclang]\
[ttk::label $w.note.pdox.pjdat.tglg -text "Targ Lang(s):"]\
[ttk::entry $w.note.pdox.pjdat.targl -textvariable tglangs]\
[ttk::label $w.note.pdox.pjdat.dude -text "Due date:"]\
[ttk::entry $w.note.pdox.pjdat.ddate -textvariable dud8]

pack $w.note.pdox.pjdat -in $w.note.pdox -fill x
frame $w.note.pdox.dlist -bd 7

grid [ttk::label $w.note.pdox.dlist.duku -text "Document list:"]\
[ttk::label $w.note.pdox.dlist.fububu -text "no. of docs:"]\
[ttk::entry $w.note.pdox.dlist.grubby -textvariable nodx]

####################
# list documents, determine target langs, no of translations per doc, no. or units (words/lines,etc) per doc, 
# then word count times no of translations per doc to give total number of units to be charged
# (I don't like the static nature of this function.  I'd like to allow the user to set the number of documents, and have the form procreate accordingly
# or start with form for one doc and have an "add doc" button to continue adding forms for more docs.
###################

grid [ttk::label $w.note.pdox.dlist.nada -text " "]\
[ttk::label $w.note.pdox.dlist.did -text "Doc ID:"]\
[ttk::label $w.note.pdox.dlist.dwc -text "Units"]\
[ttk::label $w.note.pdox.dlist.dtl -text "Targ Lang(s)"]\
[ttk::label $w.note.pdox.dlist.dntgl -text "No. of Translations"]

grid [ttk::label $w.note.pdox.dlist.nad1 -text "Doc #1:"]\
[ttk::entry $w.note.pdox.dlist.did1 -textvariable did1]\
[ttk::entry $w.note.pdox.dlist.dwc1 -textvariable dwc1]\
[ttk::entry $w.note.pdox.dlist.dtl1 -textvariable d1tl]\
[ttk::entry $w.note.pdox.dlist.dt1nt -textvariable d1no]

grid [ttk::label $w.note.pdox.dlist.nad2 -text "Doc #2:"]\
[ttk::entry $w.note.pdox.dlist.did2 -textvariable did2]\
[ttk::entry $w.note.pdox.dlist.dwc2 -textvariable dwc2]\
[ttk::entry $w.note.pdox.dlist.dtl2 -textvariable d2tl]\
[ttk::entry $w.note.pdox.dlist.dt2nt -textvariable d2no]

grid [ttk::label $w.note.pdox.dlist.nad3 -text "Doc #3:"]\
[ttk::entry $w.note.pdox.dlist.did3 -textvariable did3]\
[ttk::entry $w.note.pdox.dlist.dwc3 -textvariable dwc3]\
[ttk::entry $w.note.pdox.dlist.dtl3 -textvariable d3tl]\
[ttk::entry $w.note.pdox.dlist.dt3nt -textvariable d3no]

grid [ttk::label $w.note.pdox.dlist.nad4 -text "Doc #4:"]\
[ttk::entry $w.note.pdox.dlist.did4 -textvariable did4]\
[ttk::entry $w.note.pdox.dlist.dwc4 -textvariable dwc4]\
[ttk::entry $w.note.pdox.dlist.dtl4 -textvariable d4tl]\
[ttk::entry $w.note.pdox.dlist.dt4nt -textvariable d4no]

grid [ttk::label $w.note.pdox.dlist.nad5 -text "Doc #5:"]\
[ttk::entry $w.note.pdox.dlist.did5 -textvariable did5]\
[ttk::entry $w.note.pdox.dlist.dwc5 -textvariable dwc5]\
[ttk::entry $w.note.pdox.dlist.dtl5 -textvariable d5tl]\
[ttk::entry $w.note.pdox.dlist.dt5nt -textvariable d5no]

grid [ttk::label $w.note.pdox.dlist.nad6 -text "Doc #6:"]\
[ttk::entry $w.note.pdox.dlist.did6 -textvariable did6]\
[ttk::entry $w.note.pdox.dlist.dwc6 -textvariable dwc6]\
[ttk::entry $w.note.pdox.dlist.dtl6 -textvariable d6tl]\
[ttk::entry $w.note.pdox.dlist.dt6nt -textvariable d6no]

grid [ttk::label $w.note.pdox.dlist.nad7 -text "Doc #7:"]\
[ttk::entry $w.note.pdox.dlist.did7 -textvariable did7]\
[ttk::entry $w.note.pdox.dlist.dwc7 -textvariable dwc7]\
[ttk::entry $w.note.pdox.dlist.dtl7 -textvariable d7tl]\
[ttk::entry $w.note.pdox.dlist.dt7nt -textvariable d7no]

grid [ttk::label $w.note.pdox.dlist.nad8 -text "Doc #8:"]\
[ttk::entry $w.note.pdox.dlist.did8 -textvariable did8]\
[ttk::entry $w.note.pdox.dlist.dwc8 -textvariable dwc8]\
[ttk::entry $w.note.pdox.dlist.dtl8 -textvariable d8tl]\
[ttk::entry $w.note.pdox.dlist.dt8nt -textvariable d8no]

grid [ttk::label $w.note.pdox.dlist.clk0 -text "calculate:"]\
[ttk::label $w.note.pdox.dlist.clk -text "Src. doc units"]\
[ttk::button $w.note.pdox.dlist.chj -text "=" -command dwc]\
[ttk::label $w.note.pdox.dlist.lkj -textvariable dcwd]

grid [ttk::label $w.note.pdox.dlist.fufu -text " "]\
[ttk::label $w.note.pdox.dlist.gugu -text "no. target translations"]\
[ttk::button $w.note.pdox.dlist.cucu -text "=" -command tnt]\
[ttk::label $w.note.pdox.dlist.tutu -textvariable ttrans]

grid [ttk::label $w.note.pdox.dlist.buba -text " "]\
[ttk::label $w.note.pdox.dlist.clk1 -text "translation units"]\
[ttk::button $w.note.pdox.dlist.clk2 -text "=" -command totuns]\
[ttk::label $w.note.pdox.dlist.clk3 -textvariable tottus]

grid [ttk::label $w.note.pdox.dlist.mom -text " "]\
[ttk::label $w.note.pdox.dlist.himom -text "Price/unit:"]\
[ttk::entry $w.note.pdox.dlist.luvumom -textvariable pptu]\
[ttk::button $w.note.pdox.dlist.momisgreat -text "Totl. Trans. Charges" -command trev]\
[ttk::label $w.note.pdox.dlist.bbmom -textvariable ttrev]

pack $w.note.pdox.dlist -in $w.note.pdox -fill x

frame $w.note.pdox.dnot -bd 5

grid [ttk::label $w.note.pdox.dnot.no -text "Notes:"]
grid [ttk::entry $w.note.pdox.dnot.no2 -textvariable dnote -width 80]

pack $w.note.pdox.dnot -in $w.note.pdox -fill x

frame $w.note.pdox.menuba -relief raised -bd 2
pack $w.note.pdox.menuba -in $w.note.pdox -fill x
frame $w.note.pdox.btnz 
grid [ttk::button $w.note.pdox.menuba.rpot -text "Report" -command docport]

tk_menuBar $w.note.pdox.menuba 
focus $w.note.pdox.menuba

pack $w.note.pdox.btnz -in $w.note.pdox


#####################################################
# end first tab - project docs
#####################################################


#####################################################
# second tab - project assignments
#####################################################

ttk::frame $w.note.pass
$w.note add $w.note.pass -text "Project Assignments" -underline 0

frame $w.note.pass.tpca2 -bd 2

grid [ttk::label $w.note.pass.tpca2.labl -text "TransProCalc - Project Assignments"]
grid [ttk::label $w.note.pass.tpca2.2day -text "$date"]

pack $w.note.pass.tpca2 -in $w.note.pass -fill x

frame $w.note.pass.staf -bd 7
# basics, client, date, project no.

grid [ttk::label $w.note.pass.staf.prons -text "Project no.:"]\
[ttk::entry $w.note.pass.staf.prno -textvariable pnum]\
[ttk::label $w.note.pass.staf.cli -text "Client id:"]\
[ttk::entry $w.note.pass.staf.clnt -textvariable cid]\
[ttk::label $w.note.pass.staf.sdate -text "Start date:"]\
[ttk::entry $w.note.pass.staf.sd -textvariable begin]

grid [ttk::label $w.note.pass.staf.srcl -text "Src Lang:"]\
[ttk::entry $w.note.pass.staf.slang -textvariable srclang]\
[ttk::label $w.note.pass.staf.tglg -text "Targ Lang(s):"]\
[ttk::entry $w.note.pass.staf.targl -textvariable tglangs]\
[ttk::label $w.note.pass.staf.dude -text "Due date:"]\
[ttk::entry $w.note.pass.staf.ddate -textvariable dud8]


# scope of the project

grid [ttk::label $w.note.pass.staf.nodox -text "Ttl. No. Docs:"]\
[ttk::entry $w.note.pass.staf.ndox -textvariable nodx]\
[ttk::label $w.note.pass.staf.pintwc -text " Ttl Wd/Cnt:"]\
[ttk::entry $w.note.pass.staf.pntwc -textvariable pitwc]

pack $w.note.pass.staf -in $w.note.pass -fill x


frame $w.note.pass.asgn -bd 7

grid [ttk::label $w.note.pass.asgn.lblx -text "Assignments:"]

#############################3
# I don't like how the no. of providers is static
# I'd like to start with one, and allow the use to add form/space for addition providers at the touch of a button
# and/or take input from the user on how many providers, just as with the documents section (as planned, not as currently implemented)

# provider1 data

grid [ttk::label $w.note.pass.asgn.pv1 -text "Provider ID:"]\
[ttk::entry $w.note.pass.asgn.pv1nm -textvariable pv1]\
[ttk::label $w.note.pass.asgn.pv1nl -text " Native Lang:"]\
[ttk::entry $w.note.pass.asgn.pv1nlg -textvariable pv1tlang]\
[ttk::label $w.note.pass.asgn.pv1sv -text "Service:"]\
[ttk::entry $w.note.pass.asgn.pv1srv -textvariable pv1svc]\
[ttk::label $w.note.pass.asgn.p1tcx -textvariable texp1]

grid [ttk::label $w.note.pass.asgn.pv1d1 -text "Docs assigned:"]\
[ttk::entry $w.note.pass.asgn.pv1d1a -textvariable pv1d1]\
[ttk::label $w.note.pass.asgn.pv1d1wc -text "total units:"]\
[ttk::entry $w.note.pass.asgn.pv1d1wcn -textvariable p1twc]\
[ttk::label $w.note.pass.asgn.pv1rt -text " Rate/unit:"]\
[ttk::entry $w.note.pass.asgn.prv1r -textvariable pv1rate]\
[ttk::button $w.note.pass.asgn.p1tc -text "Prov1 cost:" -command ctexp1]


# provider2 data

grid [ttk::label $w.note.pass.asgn.pro2 -text "Provider 2:"]

grid [ttk::label $w.note.pass.asgn.pv2 -text "Provider ID:"]\
[ttk::entry $w.note.pass.asgn.pv2nm -textvariable pv2]\
[ttk::label $w.note.pass.asgn.pv2nl -text " Native Lang:"]\
[ttk::entry $w.note.pass.asgn.pv2nlg -textvariable pv2tlang]\
[ttk::label $w.note.pass.asgn.pv2sv -text "Service:"]\
[ttk::entry $w.note.pass.asgn.pv2srv -textvariable pv2svc]\
[ttk::label $w.note.pass.asgn.p2tcx -textvariable texp2]


grid [ttk::label $w.note.pass.asgn.pv2d1 -text "Docs assigned:"]\
[ttk::entry $w.note.pass.asgn.pv2d1a -textvariable pv2d1]\
[ttk::label $w.note.pass.asgn.pv2d1wc -text "total units:"]\
[ttk::entry $w.note.pass.asgn.pv2d1wcn -textvariable p2twc]\
[ttk::label $w.note.pass.asgn.pv2rt -text " Rate/unit:"]\
[ttk::entry $w.note.pass.asgn.prv2r -textvariable pv2rate]\
[ttk::button $w.note.pass.asgn.p2tc -text "Prov2 cost:" -command ctexp2]

# provider3 data

grid [ttk::label $w.note.pass.asgn.pro3 -text "Provider 3:"]

grid [ttk::label $w.note.pass.asgn.pv3 -text "Provider ID:"]\
[ttk::entry $w.note.pass.asgn.pv3nm -textvariable pv3]\
[ttk::label $w.note.pass.asgn.pv3nl -text " Native Lang:"]\
[ttk::entry $w.note.pass.asgn.pv3nlg -textvariable pv3tlang]\
[ttk::label $w.note.pass.asgn.pv3sv -text "Service:"]\
[ttk::entry $w.note.pass.asgn.pv3srv -textvariable pv3svc]\
[ttk::label $w.note.pass.asgn.p3tcx -textvariable texp3]


grid [ttk::label $w.note.pass.asgn.pv3d1 -text "Docs assigned:"]\
[ttk::entry $w.note.pass.asgn.pv3d1a -textvariable pv3d1]\
[ttk::label $w.note.pass.asgn.pv3d1wc -text "total units:"]\
[ttk::entry $w.note.pass.asgn.pv3d1wcn -textvariable p3twc]\
[ttk::label $w.note.pass.asgn.pv3rt -text " Rate/unit:"]\
[ttk::entry $w.note.pass.asgn.prv3r -textvariable pv3rate]\
[ttk::button $w.note.pass.asgn.p3tc -text "Prov3 cost:" -command ctexp3]


# provider4 data

grid [ttk::label $w.note.pass.asgn.pro4 -text "Provider 4:"]

grid [ttk::label $w.note.pass.asgn.pv4 -text "Provider ID:"]\
[ttk::entry $w.note.pass.asgn.pv4nm -textvariable pv4]\
[ttk::label $w.note.pass.asgn.pv4nl -text " Native Lang:"]\
[ttk::entry $w.note.pass.asgn.pv4nlg -textvariable pv4tlang]\
[ttk::label $w.note.pass.asgn.pv4sv -text "Service:"]\
[ttk::entry $w.note.pass.asgn.pv4srv -textvariable pv4svc]\
[ttk::label $w.note.pass.asgn.p4tcx -textvariable texp4]


grid [ttk::label $w.note.pass.asgn.pv4d1 -text "Docs assigned:"]\
[ttk::entry $w.note.pass.asgn.pv4d1a -textvariable pv4d1]\
[ttk::label $w.note.pass.asgn.pv4d1wc -text "total units:"]\
[ttk::entry $w.note.pass.asgn.pv4d1wcn -textvariable p4twc]\
[ttk::label $w.note.pass.asgn.pv4rt -text " Rate/unit:"]\
[ttk::entry $w.note.pass.asgn.prv4r -textvariable pv4rate]\
[ttk::button $w.note.pass.asgn.p4tc -text "Prov4 cost:" -command ctexp4]


# provider 5 data

grid [ttk::label $w.note.pass.asgn.pro5 -text "Provider 5:"]

grid [ttk::label $w.note.pass.asgn.pv5 -text "Provider ID:"]\
[ttk::entry $w.note.pass.asgn.pv5nm -textvariable pv5]\
[ttk::label $w.note.pass.asgn.pv5nl -text " Native Lang:"]\
[ttk::entry $w.note.pass.asgn.pv5nlg -textvariable pv5tlang]\
[ttk::label $w.note.pass.asgn.pv5sv -text "Service:"]\
[ttk::entry $w.note.pass.asgn.pv5srv -textvariable pv5svc]\
[ttk::label $w.note.pass.asgn.p5tcx -textvariable texp5]


grid [ttk::label $w.note.pass.asgn.pv5d1 -text "Docs assigned:"]\
[ttk::entry $w.note.pass.asgn.pv5d1a -textvariable pv5d1]\
[ttk::label $w.note.pass.asgn.pv5d1wc -text "total units:"]\
[ttk::entry $w.note.pass.asgn.pv5d1wcn -textvariable p5twc]\
[ttk::label $w.note.pass.asgn.pv5rt -text " Rate/unit:"]\
[ttk::entry $w.note.pass.asgn.prv5r -textvariable pv5rate]\
[ttk::button $w.note.pass.asgn.p5tc -text "Prov5 cost:" -command ctexp5]


# total cost all providers

grid [ttk::button $w.note.pass.asgn.tttt -text "Assigned units" -comman tpunits]\
[ttk::label $w.note.pass.asgn.ttuu -textvariable totpun]\
[ttk::button $w.note.pass.asgn.tptxp -text "Ttl Prov Costs" -command tpcost]\
[ttk::label $w.note.pass.asgn.tppp -textvariable totpx]

pack $w.note.pass.asgn -in $w.note.pass

frame $w.note.pass.notz -bd 5
pack $w.note.pass.notz -in $w.note.pass -fill x

grid [ttk::label $w.note.pass.notz.not -text "Notes:"]\
[ttk::entry $w.note.pass.notz.note  -textvariable note2 -width 85]

# button menu for pjout

frame $w.note.pass.menubab -relief raised -bd 2
pack $w.note.pass.menubab -in $w.note.pass -fill x
frame $w.note.pass.butnz 
grid [ttk::button $w.note.pass.menubab.rpot -text "Report" -command paport]


tk_menuBar $w.note.pass.menubab 
focus $w.note.pass.menubab

pack $w.note.pass.butnz -in $w.note.pass 


######################################################
# end second tab - project assignments
######################################################


#####################################################
# third tab - project financial
# here's where we crunch up the financial numbers...all about the Benjamins!
#  SHOW ME THE MONEY!!!!
# as with other sections, I'd like the use to have more control over how many "additional charges" and "additional expenses", etc.
# go
#####################################################
ttk::frame $w.note.pjin
$w.note add $w.note.pjin -text "Project Financial" -underline 0

frame $w.note.pjin.tpc2 -bd 2

grid [ttk::label $w.note.pjin.tpc2.labl -text "TransProCalc Project Financial"]
grid [ttk::label $w.note.pjin.tpc2.day -textvariable date]

pack $w.note.pjin.tpc2 -in $w.note.pjin -fill x

frame $w.note.pjin.stuf -bd 7

# basics, client, date, project no.

grid [ttk::label $w.note.pjin.stuf.prons -text "Project no.:"]\
[ttk::entry $w.note.pjin.stuf.prno -textvariable pnum]\
[ttk::label $w.note.pjin.stuf.cli -text "Client id:"]\
[ttk::entry $w.note.pjin.stuf.clnt -textvariable cid]

grid [ttk::label $w.note.pjin.stuf.sdate -text "Start date:"]\
[ttk::entry $w.note.pjin.stuf.sd -textvariable begin]\
[ttk::label $w.note.pjin.stuf.dude -text "Due date:"]\
[ttk::entry $w.note.pjin.stuf.ddate -textvariable dud8]

grid [ttk::label $w.note.pjin.stuf.unit -text "invoice no."]\
[ttk::entry $w.note.pjin.stuf.inv -textvariable invo]\
[ttk::label $w.note.pjin.stuf.ddd8 -text "Date delivered:"]\
[ttk::entry $w.note.pjin.stuf.dd8d -textvariable d8dl]

grid [ttk::label $w.note.pjin.stuf.dpad -text "Invoice Due:"]\
[ttk::entry $w.note.pjin.stuf.dpid -textvariable idud8]\
[ttk::label $w.note.pjin.stuf.g7h -text "Date paid:"]\
[ttk::entry $w.note.pjin.stuf.h7g -textvariable dtpd]

grid [ttk::label $w.note.pjin.stuf.nodox -text "No. Docs:"]\
[ttk::entry $w.note.pjin.stuf.ndox -textvariable nodx]\
[ttk::label $w.note.pjin.stuf.pintwc -text "Trans. Units:"]\
[ttk::entry $w.note.pjin.stuf.pntwc -textvariable tottus]
grid [ttk::label $w.note.pjin.stuf.whazu -text "Price/unit:"]\
[ttk::entry $w.note.pjin.stuf.whaza -textvariable pptu]\
[ttk::button $w.note.pjin.stuf.sxabu -text "Trans. Charges:" -command trev]\
[ttk::label $w.note.pjin.stuf.werty -textvariable ttrev]

# additional charges? (postage, notary, Printing, etc.)
grid [ttk::label $w.note.pjin.stuf.su45n -text "Additional"]\
[ttk::label $w.note.pjin.stuf.st3v4i -text "miscellaneous"]\
[ttk::label $w.note.pjin.stuf.nh89 -text "charges:"]

grid [ttk::label $w.note.pjin.stuf.fadad -text "Purpose"]\
[ttk::entry $w.note.pjin.stuf.adcxe -textvariable adchx1]\
[ttk::label $w.note.pjin.stuf.milfs -text "Amount"]\
[ttk::entry $w.note.pjin.stuf.acgop -textvariable adchx1t]

grid [ttk::label $w.note.pjin.stuf.adcrap -text "Purpose"]\
[ttk::entry $w.note.pjin.stuf.ad2cxe -textvariable adchx2]\
[ttk::label $w.note.pjin.stuf.adpoop -text "Amount"]\
[ttk::entry $w.note.pjin.stuf.ac2gop -textvariable adchx2t]

grid [ttk::button $w.note.pjin.stuf.chargalot -text "Ttl Adl Chgs" -command aditup]\
[ttk::label $w.note.pjin.stuf.wopo -textvariable aladch]\
[ttk::button $w.note.pjin.stuf.esti -text "Total Charges" -command stik]\
[ttk::label $w.note.pjin.stuf.ruxuf -textvariable allCharges]

grid [ttk::label $w.note.pjin.stuf.px -text "Provider expenses:"]\
[ttk::entry $w.note.pjin.stuf.px2 -textvariable totpx]\
[ttk::label $w.note.pjin.stuf.px3 -text "(from assign)"]

# addl projects costs? 
grid [ttk::label $w.note.pjin.stuf.suop -text "Additional"]\
[ttk::label $w.note.pjin.stuf.sumtn -text "Project"]\
[ttk::label $w.note.pjin.stuf.h89 -text "expenses:"]

grid [ttk::label $w.note.pjin.stuf.nadad -text "Purpose"]\
[ttk::entry $w.note.pjin.stuf.nubun -textvariable adex1]\
[ttk::label $w.note.pjin.stuf.milin -text "Amount"]\
[ttk::entry $w.note.pjin.stuf.bubn -textvariable adex1t]\

grid [ttk::label $w.note.pjin.stuf.adcx -text "Purpose"]\
[ttk::entry $w.note.pjin.stuf.grubne -textvariable adex2]\
[ttk::label $w.note.pjin.stuf.adpp -text "Amount"]\
[ttk::entry $w.note.pjin.stuf.bilbn -textvariable adex2t]

grid [ttk::label $w.note.pjin.stuf.attiocx -text "Purpose"]\
[ttk::entry $w.note.pjin.stuf.nub7n -textvariable adex3]\
[ttk::label $w.note.pjin.stuf.adp9ip -text "Amount"]\
[ttk::entry $w.note.pjin.stuf.b7bn -textvariable adex3t]


grid [ttk::button $w.note.pjin.stuf.chargemo -text "Ttl Adl Cost" -command adexup]\
[ttk::label $w.note.pjin.stuf.gimi -textvariable aladex]\
[ttk::button $w.note.pjin.stuf.smaku -text "Expenses" -command sux]\
[ttk::label $w.note.pjin.stuf.gorp4 -textvariable allSux]

# Here we figure up the estimated gross profit (before tax)
# We might as well be hopeful at this stage.

grid [ttk::label $w.note.pjin.stuf.aldon -text "Calculate totals:"]\
[ttk::button $w.note.pjin.stuf.hoops -text "Gross Profit:" -command estim8]\
[ttk::label $w.note.pjin.stuf.score -textvariable gross]

grid  [ttk::label $w.note.pjin.stuf.txrt -text "tax rate"] \
[ttk::label $w.note.pjin.stuf.txrt1 -text "(% as decimal, ie. 0.15)"]\



# now calculate tax
grid [ttk::label $w.note.pjin.stuf.trate -text "tax %: "] \
[ttk::entry $w.note.pjin.stuf.tr8 -textvariable trate]\
[ttk::button $w.note.pjin.stuf.tax -text "taxes:" -command caltax]\
[ttk::label $w.note.pjin.stuf.taxs -textvariable tax] 

# show tax and profit after tax

grid [ttk::label $w.note.pjin.stuf.lobk -text "$$$$"]\
[ttk::label $w.note.pjin.stuf.lobw -text "SHOW ME THE $$$$:"]\
[ttk::button $w.note.pjin.stuf.net -text "net profit:" -command calnet]\
[ttk::label $w.note.pjin.stuf.netp -textvariable net]

pack $w.note.pjin.stuf -in $w.note.pjin

frame $w.note.pjin.notz -bd 5
pack $w.note.pjin.notz -in $w.note.pjin -fill x

grid [ttk::label $w.note.pjin.notz.not -text "Notes:"]\
[ttk::entry $w.note.pjin.notz.note  -textvariable note1 -width 70]

# button menu for pjout

frame $w.note.pjin.menubab -relief raised -bd 2
pack $w.note.pjin.menubab -in $w.note.pjin -fill x
frame $w.note.pjin.butnz 
grid [ttk::button $w.note.pjin.menubab.rpot -text "Report" -command piport]


tk_menuBar $w.note.pjin.menubab 
focus $w.note.pjin.menubab

pack $w.note.pjin.butnz -in $w.note.pjin 
# pack $w.note.pjin 
#-in $w.note -side left

#####################################################
# end third tab - project financial
#####################################################


#####################################################
# tab four - report editor
# ###################################################



proc About {} {
 toplevel .msg
wm title .msg "About TransProCalc"

message  .msg.msg1 -text "TransProCalc-Translation Project Calculator\nby Tony Baldwin\nhttp://www.tonybaldwin.me\n ----  \n*ProjectDocs-\nassist you in sorting out multiple document/provider/language jobs, and will generate total translation units for your project estimate/charges.\n*ProjectAssign-\nhelps you record project component assignments, to assist in project management, and \n*ProjectFin-\nassists you in estimating project costs and profits for potential or new projects, and/or, helps you manage and record relevant financial data at the end of a project.\n ----\nTransProCalc is Free/Open Source Software \nsubject to the terms of the Gnu Public License \nSee www.fsf.org for further information.\n"

pack .msg.msg1 -in .msg -side top

button .msg.btn -text "okay" -command {destroy .msg}
pack .msg.btn -in .msg -side bottom

}


proc saveproject {} {
	set novar "cows"
set header "#!/usr/bin/env wish8.5 "
   set file_types {
     {"TransProCalc" {.tpc}}
    }
   set filename [tk_getSaveFile -filetypes $file_types]
   set fileid [open $filename w]
   puts $fileid $header
   foreach var $::allvars {puts $fileid [list set $var [set ::$var]]}
   close $fileid
} 

proc openproject {} {
     set file_types {
     {"TransProCalc" {.tpc}}
    }
set project [tk_getOpenFile -filetypes $file_types]
uplevel #0 [list source $project]
}

proc Reset {} {
foreach var $::allvars {global $var}
foreach var $::allvars {set $var " "}
}


proc quicke {} {

toplevel .quick
wm title .quick "TransProCalc - Quick Estimate"

grid [ttk::label .quick.lbl -text "TransProCalc"]\
[ttk::label .quick.lbl2 -text "Quick Estimate"]

grid [ttk::label .quick.wird -text "word count: "] \
[ttk::entry .quick.wc -textvariable wrds] 
grid [ttk::label .quick.rate -text "rate/word: "] \
[ttk::entry .quick.r8 -textvariable rate]
grid [ttk::button .quick.calc -text "PRICE:" -command calculate]\
[ttk::label .quick.price -textvariable price] 

grid [ttk::label .quick.labk -text "-----------------"]\
[ttk::label .quick.labw -text "-------------------------------"]

grid [ttk::label .quick.pdo -text "pd/out: "] \
[ttk::entry .quick.po -textvariable pout]

# Get gross profit, after expense:

grid [ttk::button .quick.inc -text "income" -command calinc]\
[ttk::label .quick.incm -textvariable income] 

# now calculate tax

grid [ttk::button .quick.tax -text "taxes:" -command qtax]\
[ttk::label .quick.taxs -textvariable tax] 

# show tax and profit after tax

grid [ttk::label .quick.lobk -text "------------------"]\
[ttk::label .quick.lobw -text "-------------------------------"]

grid [ttk::button .quick.net -text "net profit:" -command qnet]\
[ttk::label .quick.netp -textvariable net]


grid [ttk::label .quick.labt -text "-------------------"]\
[ttk::label .quick.labg -text "------------------------------"]
# I like to see how much I made per hour for my work,
# I enter all hours translating, proofreading, managing the project, etc.

grid [ttk::label .quick.hrs -text "hours: "] \
[ttk::entry .quick.l2 -textvariable hour]
grid [ttk::button .quick.calc2 -text "WAGE/HR:" -command calculate2]\
[ttk::label .quick.wage -textvariable wage] 

grid [ttk::button .quick.did -text "Close" -command {destroy .quick}]


}

proc calculate {} {  
   if {[catch {
       set ::price [expr {$::wrds*$::rate}]
   }]!=0} {
       set ::price ""
   }
}

proc calculate2 {} {  
   if {[catch {
       set ::wage [expr {$::income/$::hour}]
   }]!=0} {
       set ::wage ""
   }
}

proc qnet {} {  
   if {[catch {
       set ::net [expr {$::income-$::tax}]
   }]!=0} {
       set ::net ""
   }
}

proc calinc {} {  
   if {[catch {
       set ::income [expr {$::price-$::pout}]
   }]!=0} {
       set ::income ""
   }
}

proc qtax {} {  
   if {[catch {
       set ::tax [expr {$::income*0.15}]
   }]!=0} {
       set ::tax ""
   }
}

# total word (or unit) count from all docs
proc dwc {} {
  if {[catch {
	set ::dcwd [expr {($::dwc1+$::dwc2+$::dwc3+$::dwc4+$::dwc5+$::dwc6+$::dwc7+$::dwc8)}]
  }]!=0} {
	set ::dcwd "?"
  }
}

proc tnt {} {
  if {[catch {
	set ::ttrans [expr {($::d1no+$::d2no+$::d3no+$::d4no+$::d5no+$::d6no+$::d7no+$::d8no)}]
  }]!=0} {
	set ::ttrans "?"
  }
}

# total translation units  =  doc wd count X no. of translations (target langs) 
# (ie. if sillydoc.odt is the only doc, and it is to be
# translated to DE and FR, and has 202 words, the tot trans units are 404.

proc totuns {} {
  if {[catch {
	set ::tottus [expr {(($::dwc1*$::d1no)+($::dwc2*$::d2no)+($::dwc3*$::d3no)+($::dwc4*$::d4no)+($::dwc5*$::d5no)+($::dwc6*$::d6no)+($::dwc7*$::d7no)+($::dwc8*$::d8no))}]
  }]!=0} {
	set ::tottus "?"
  }
}

# translation charges from project doc mgr
proc trev {} {
  if {[catch {
	set ::ttrev [expr {$::tottus*$::pptu}]
  }]!=0} {
	set ::ttrev "?"
  }
}


# formula for tax
# looks like I'm being optimistic, eh?
proc caltax {} {  
   if {[catch {
       set ::tax [expr {$::gross*$::trate}]
   }]!=0} {
       set ::tax "?"
   }
}
# calculate profit after tax
proc calnet {} {  
   if {[catch {
       set ::net [expr {$::gross-$::tax}]
   }]!=0} {
       set ::net "?"
   }
}
# total provider cost per provider
proc ctexp1 {} {
  if {[catch {
	set ::texp1 [expr {$::p1twc*$::pv1rate}]
   }]!=0} {
	set ::texp1 "?"
   }
} 

# provider 2
proc ctexp2 {} {
  if {[catch {
	set ::texp2 [expr {$::p2twc*$::pv2rate}]
   }]!=0} {
	set ::texp2 "?"
   }
} 

# provider 3 (I should add some more providers)
proc ctexp3 {} {
  if {[catch {
	set ::texp3 [expr {$::p3twc*$::pv3rate}]
   }]!=0} {
	set ::texp3 "?"
   }
} 

# provider 3 (I should add some more providers)
proc ctexp4 {} {
  if {[catch {
	set ::texp4 [expr {$::p4twc*$::pv4rate}]
   }]!=0} {
	set ::texp4 "?"
   }
} 

# provider 3 (I should add some more providers)
proc ctexp5 {} {
  if {[catch {
	set ::texp5 [expr {$::p5twc*$::pv5rate}]
   }]!=0} {
	set ::texp5 "?"
   }
} 


# total provider costs 
proc tpcost {} {
  if {[catch {
	set ::totpx [expr {$::texp1+$::texp2+$::texp3+$::texp4+$::texp5}]
  }]!=0} {
	set ::totpx "?"
   }
}
# adding additional miscellaneous charges
proc aditup {} {
  if {[catch {
	set ::aladch [expr {$::adchx1t+$::adchx2t}]
  }]!=0} {
	set ::aladch "?"
  }
}

# adding additional projected expenses
proc adexup {} {
  if {[catch {
	set ::aladex [expr {$::adex1t+$::adex2t+$::adex3t}]
  }]!=0} {
	set ::aladex "?"
  }
}

# add all charges
proc stik {} {
  if {[catch {
	set ::allCharges [expr {$::aladch+$::ttrev}]
  }]!=0} {
	set ::allCharges "?"
  }
}
#  add all project expenses
proc sux {} {
if {[catch {
		set ::allSux [expr {$::aladex+$::totpx}]
	}]!=0} {
	set ::allSux "?"
   }
}
#
proc estim8 {} {
  if {[catch {
	set ::gross [expr {$::allCharges-($::aladex+$::totpx)}]
  }]!=0} {
	set ::gross "?"
  }
}

# total units assigned to providers
proc tpunits {} {
  if {[catch {
	set ::totpun [expr {$::p1twc+$::p2twc+$::p3twc+$::p4twc+$::p5twc}]
  }]!=0} {
	set ::totpun "?"
  }
}

# this is the project document report:

proc docport {} {

toplevel .drpt
wm title .drpt "TPC Document Report"


frame .drpt.fr -width 85 -height 45

pack .drpt.fr

frame .drpt.menubar -relief raised -bd 2
pack .drpt.menubar -in .drpt.fr -fill x
frame .drpt.edf 

grid [ttk::button .drpt.menubar.save -text "Save Report" -command {saveasd}]\
[ttk::button .drpt.menubar.print -text "Print" -command {prntd}]\
[ttk::button .drpt.menubar.quit -text "Close" -command {destroy .drpt}]


tk_menuBar .drpt.menubar 
focus .drpt.menubar

text .drpt.docReport -width 80 -height 40

set date [clock format [clock seconds] -format "%m / %d / %Y"]

	.drpt.docReport insert end " TransProCalc: Documents Report \n ====================================\n Date: $date\n ================PROJECT===============\n  Project No: $::pnum	Client ID:   $::cid \n  Begin date:  $::begin		Due date:    $::dud8 \n  Source Langs(s): $::srclang	Target Langs: $::tglangs  \n  Total Docs: $::nodx  \n ===============DOCUMENTS================\n Doc ID - Units - Targets - No. of Translations \n Doc 1: $::did1	- $::dwc1 - $::d1tl - $::d1no\n Doc 2: $::did2	- $::dwc2 - $::d2tl - $::d2no\n Doc 3: $::did3	- $::dwc3 - $::d3tl - $::d3no\n Doc 4: $::did4	- $::dwc4 - $::d4tl - $::d4no\n Doc 5: $::did5	- $::dwc5 - $::d5tl - $::d5no\n Doc 6: $::did6	- $::dwc6 - $::d6tl - $::d6no\n Doc 7: $::did7	- $::dwc7 - $::d7tl - $::d7no\n Doc 8: $::did8	- $::dwc8 - $::d8tl - $::d8no\n ==========================================\n Total word count from documents = $::dcwd\n Total number of target translations = $::ttrans\n Total no. of translation units = $::tottus\n Price/unit: $::pptu	Total translation charges:  $::ttrev\n ==================NOTES================== \n Notes:$::dnote \n ========================================= \n Report generated by TransProCalc \n Translation Project Calculator \n http://www.TransProCalc.org "

pack .drpt.docReport 
pack .drpt.edf -in .drpt.fr -after .drpt.menubar

}

proc piport {} {  

toplevel .prp 
wm title .prp "TPC Project Financial Report"

frame .prp.fr -width 85 -height 45

pack .prp.fr

frame .prp.menubar -relief raised -bd 2
pack .prp.menubar -in .prp.fr -fill x
frame .prp.edf 

grid [ttk::button .prp.menubar.save -text "Save Report" -command {saveasp}]\
[ttk::button .prp.menubar.print -text "Print" -command {prnte}]\
[ttk::button .prp.menubar.quit -text "Close" -command {destroy .prp}]


tk_menuBar .prp.menubar 
focus .prp.menubar

text .prp.pinReport -width 80 -height 40

set date [clock format [clock seconds] -format "%m / %d / %Y"]

	.prp.pinReport insert end " TransProCalc: Project Financial Report \n ====================================\n Date: $date\n ================PROJECT===============\n Project No: $::pnum	Client ID:   $::cid \n Begin date:  $::begin		Delivery date:  $::d8dl Invoice due: $::idud8 \n  \n Source Langs(s): $::srclang	Target Langs: $::tglangs  \n Total Docs: $::nodx		Total Units:  $::tottus  \n Price/unit: $::pptu\n ================CHARGES================\n Translations charges: $::ttrev \n Additional charges:\n ------------------------- \n Charge: $::adex1  Amount: $::adex1t \n Charge: $::adex2  Amount: $::adex2t \n Total Additional Charges: $::aladch \n ---------------------------------------------\n 	*TOTAL PROJECT CHARGES: $::allCharges \n =================EXPENSES================\n Providers expenses: $::totpx \n Expense: $::adex1	 Amount: $::adex1t \n Expense: $::adex2	 Amount: $::adex2t \n Expense: $::adex3	 Amount: $::adex3t \n Expense: $::adex4	 Amount: $::adex4t \n ----------------------------------------------\n 	*TOTAL EST. PROJECT EXPENSE: $::allSux \n =====================================\n 	*GROSS PROFITS: $::gross \n ==================TAXES================= \n Est. tax rate: $::trate	| Est. tax amount: $::tax \n ================NET PROFIT============== \n Net Profit = $::curnc $::net \n ====================================\n Notes: $::note1 \n Report generated by TransProCalc \n http://www.TransProCalc.org"
pack .prp.pinReport
 
pack .prp.edf -in .prp.fr -after .prp.menubar

}


proc paport {} {  

toplevel .pap 
wm title .pap "TPC Project Assignment Report"

frame .pap.fr -width 85 -height 45

pack .pap.fr

frame .pap.menubar -relief raised -bd 2
pack .pap.menubar -in .pap.fr -fill x
frame .pap.edf 

grid [ttk::button .pap.menubar.save -text "Save Report" -command {saveasa}]\
[ttk::button .pap.menubar.print -text "Print" -command {prnta}]\
[ttk::button .pap.menubar.quit -text "Close" -command {destroy .pap}]


tk_menuBar .pap.menubar 
focus .pap.menubar

text .pap.pasprt -width 80 -height 40

set date [clock format [clock seconds] -format "%m / %d / %Y"]

	.pap.pasprt insert end " TransProCalc: Project Assignments \n ====================================\n Date: $date\n ================PROJECT===============\n Project No: $::pnum	Client ID:   $::cid \n Begin date:  $::begin		Due date:    $::dud8 \n Source Langs(s): $::srclang	Target Langs: $::tglangs  \n Total Docs: $::nodx		Total Units:  $::totpun  \n Price/unit: $::pptu\n =====================================\n Provider 1:$::pv1  TargLang: $::pv1tlang Service: $::pv1svc\n Docs Assigned: $::pv1d1\n Total Units: $::p1twc Rate: $::pv1rate Provider Fees: $::texp1\n --\n Provider 2:$::pv2  TargLang: $::pv2tlang Service: $::pv2svc \n Docs Assigned: $::pv2d1\n Total Units: $::p2twc Rate: $::pv2rate Provider Fees: $::texp2\n --\n Provider 3:$::pv3  TargLang: $::pv3tlang Service: $::pv3svc \n Docs Assigned: $::pv3d1\n Total Units: $::p3twc Rate: $::pv3rate Provider Fees: $::texp3\n --\n Provider 4:$::pv4  TargLang: $::pv4tlang Service: $::pv4svc \n Docs Assigned: $::pv4d1\n Total Units: $::p4twc Rate: $::pv4rate Provider Fees: $::texp4\n --\n Provider 5:$::pv5  TargLang: $::pv5tlang Service: $::pv5svc \n Docs Assigned: $::pv5d1\n Total Units: $::p5twc Rate: $::pv5rate Provider Fees: $::texp5\n =====================================\n 	Providers expenses: $::totpx \n =====================================\n Notes: $::note2\n =====================================\n Report generated by TransProCalc \n www.TransProCalc.org"
pack .pap.pasprt
}

proc saveasp {} {
   set file_types {
     {"Text Files" { .txt .TXT} }
     {"All Files" * }
    }
   set filename [tk_getSaveFile -filetypes $file_types]
   set data [.prp.pinReport get 1.0 {end -1c}]
   set fileid [open $filename w]
   puts -nonewline $fileid $data
   close $fileid
}
proc saveasd {} {
   set file_types {
     {"Text Files" { .txt .TXT} }
     {"All Files" * }
    }
   set filename [tk_getSaveFile -filetypes $file_types]
   set data [.drpt.docReport get 1.0 {end -1c}]
   set fileid [open $filename w]
   puts -nonewline $fileid $data
   close $fileid
}

proc saveasa {} {
   set file_types {
     {"Text Files" { .txt .TXT} }
     {"All Files" * }
    }
   set filename [tk_getSaveFile -filetypes $file_types]
   set data [.pap.pasprt get 1.0 {end -1c}]
   set fileid [open $filename w]
   puts -nonewline $fileid $data
   close $fileid
}

proc saveas {} {
   set file_types {
     {"Text Files" { .txt .TXT} }
     {"All Files" * }
    }
   set filename [tk_getSaveFile -filetypes $file_types]
   set data [.rp.finReport get 1.0 {end -1c}]
   set fileid [open $filename w]
   puts -nonewline $fileid $data
   close $fileid
}

proc prnta {} {
	set data [.pap.pasprt get 1.0 {end -1c}]
	set fileid [open $::filename w]
	puts -nonewline $fileid $data
	close $fileid
	exec cat $::filename | lpr
}


proc prnt0 {} {
	set data [.rp.finReport get 1.0 {end -1c}]
	set fileid [open $::filename w]
	puts -nonewline $fileid $data
	close $fileid
	exec cat $::filename | lpr
}

proc prnte {} {
	set data [.prp.pinReport get 1.0 {end -1c}]
	set fileid [open $::filename w]
	puts -nonewline $fileid $data
	close $fileid
	exec cat $::filename | lpr
}


proc prntd {} {
	set data [.drpt.docReport get 1.0 {end -1c}]
	set fileid [open $::filename w]
	puts -nonewline $fileid $data
	close $fileid
	exec cat $::filename | lpr
}

# This program was written by Anthony Baldwin / tony@baldwinsoftware.com
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 2 of the License, or
# (at your option) any later version.

# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.

# You should have received a copy of the GNU General Public License
# along with this program; if not, write to the Free Software
# Foundation, Inc., 675 Mass Ave, Cambridge, MA 02139, USA.
