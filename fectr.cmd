@SETLOCAL ENABLEEXTENSIONS
@c:\strawberry\perl\bin\perl.exe -x "%~f0" %* && pause
@exit /b %ERRORLEVEL%
#!perl
# The above code creates a Perl based droplet handler feature for MS Windows and requires strawberry perl to be installed
# Filename: fectr.cmd
# Author: Jason Campisi
# Date: copyleft 12/11/09 - 2013
# Release under the GPL 2 or higher | http://www.gnu.org/licenses/gpl.html
# Requirements: MS Windows, Stawberry Perl 5.x, & Windows Notepad for printing
# Tested on: Windows XP, Windows 7 Pro & 8 Pro
# 
# Support for Linux / OS X Support: None, unless you remove droplet code and tweak the printing system call.
#
# Purpose: A windows droplet program that takes Fedex's Desktop Ship Manager's "End of Day" report 
# 	that is stored in a text-file and harvest the cost, tracking, name data in the list 
#	and display the results, along with total cost and parcels processed. Then, print the report 
#	if desired.
#
# Designed Goal: Ease of use for JoeSixPack that contains features that *nix minded people would want.
#  In other words, built for the command line or users that can only understand dragging a report 
#  file onto a shortcut that will display desired results using pre-set settings.
#
#  It must also offer a means to check that it is working properly for pointy-hair managers to believe
#  the results, and provide quick debugging to tweak pattern-matching code for when FedEx changes
#  their report file format or tracking numbers.
#
# History: originally, created to track the cost of outgoing Cisco Brewers (ciscobrewers.com) 
#  alcohol shipments.	
#
# NOTE: The format of FedEx Report's sometimes change & the pattern-matching code might need tweaking
#

$|=1; # forces a flush after every write or print
use Data::Dumper;
use strict;
use File::Temp;
use constant APPNAME => "FECTR: FedEx Cost-Total ReportReader";
use constant FILENAME => "fectr.cmd";
use constant VERSION => "0.6.3";
use constant COPYLEFT => "Copyleft 2009-2013";
use constant NL => "\r\n";
use constant PRINTER => "%windir%\\system32\\notepad.exe";

##  options: debug, terminal-display-only, help, verbose, cost-total-only silent-mode, pkg total, recipient's name find tracking#s, no-print
use constant OPTIONS => "dthvcprfn"; 			
my ($TEMP, %opt, %pattern) = (File::Temp->new(SUFFIX => ".txt"),{"cost","track","name"}); #temp-file report, store which cmdline options are activated, regex patterns
   $pattern{cost}  = qr/^\d{12,22}\s*\d{1,4}\.\d{2}\s*\w{2}\s*\w\s*(\d{1,4}\.\d{2})/;	  #capture cost column
   $pattern{track} = qr/^(\d{12,22})/;
   $pattern{name}  = qr/^\d{12,22}\s*\d{1,4}\.\d{2}\s*\w{2}\s*\w\s*\d{1,4}\.\d{2}\s*((c[\s*|\\|\/]+o\s*)?\w*\W*\w*)/i; #find names
   
sub main() {
   cmdlnParm();					#check if any options and files were passed to the program and filter them

  #display info about the program
   print NL . "Temp Report Log: " . $TEMP->filename . NL if ($opt{t} or $opt{d});
   p('-' x length(APPNAME . " - v" . VERSION) . NL . APPNAME . " - v" . VERSION . NL);
   
   foreach (@ARGV){ p("Report Data File: $_" . NL); }   #show which valid files are being used
   if ($opt{d}){ #debug mode - show regex patterns for possible tweaking if FedEx changes the report-format
 	  foreach (sort keys %pattern){ p( "Capture " . $_ . " Regex: ". Data::Dumper->Dump([\$pattern{$_}]) ); }
	  p("");
   }
   
   if ($opt{r} and $opt{f}){ p("FedEx Shipping Info:"); }
   else { p("FedEx Shipping Cost:"); }
   
   my @r = processFile(); #package totals, sum the costs of shipping from FedEx Report file(s)

  #display final results
   if ($r[0] >= 0 or $r[1] >= 0){	#check the pkg-count & total cost
      p(NL . "Total Parcel Count: " . $r[0] . NL . "Total Shipping Cost: \$". $r[1]);
	  if (! ($opt{t} or $opt{c} or $opt{p})){                          # open report in notepad?
	      if ( $opt{n}) {    system(PRINTER, $TEMP->filename); }       # open tempfile in notepad - don't print	 
		  else {			 system(PRINTER, "/P", $TEMP->filename); } #"/P" prints to the default printer 
		  #did opening in notepad and/or printing fail?
		  if ($?==-1){ warn "\nError: Failed to open this report in NotePad and/or print\n"; }
		  else {       print NL . "-->This Report Has Been Sent To The Printer" . NL if (!$opt{n}); }	
	  }else {
		  print "$r[0]\t" if $opt{p};	#just display total # of packages & nothing-else 
		  print "$r[1]"   if $opt{c};	#just display total cost & nothing-else 
		  print NL;
	  }
   }else { warn "Something is wrong with the shipping info.\n Total packages = " . $r[0] . " & Total Cost = " . $r[1] . "\n"; }	
   File::Temp::cleanup(); 
} #end main

sub processFile(){ 	#parses the files and returns @result=("package count","total cost")
 my ($pkg_count, $sum) = (0,0);	#package count & total cost
 
  foreach (<>){                     #read the provided file(s), line by line
	next if ( $_ =~/^\s?$/ );       #skip whitespace lines
	chop $_;
	p("line: $_") if ($opt{d});		# Display data-file lines for debugging only
	my ($cost, $name, $track) = (0,"","");
	 
	#if the pattern fails to match, it has a return value of 0
	$cost=$1  if ( m/$pattern{cost}/ );             #Capture the cost column
 	next      unless ($cost > 0);                   #if no cost, then no point looking for anything else
	$track=$1 if ( $opt{f} && m/$pattern{track}/ ); #Capture the tracking number column
	if ( $opt{r} && (m/$pattern{name}/) ){  #Capture the recipient's name column   
		$name=$1
	}
	
	$sum+=$cost;	    					#sum all the cost values together
	++$pkg_count;
	p($_) if $opt{v};						#check to see if the data captured is right from the current line
	 
	if ($opt{f} > 0 or $opt{r} > 0){		#display recipient-name and/or tracking?
	   if( $opt{f} and $opt{r}){ p(sprintf ("%-22s %-20s", $track, $name)); next; }
	   elsif ($opt{f} > 0){ p( sprintf ("%-22s", $track) ); }
	   elsif ($opt{r} > 0){ p( sprintf ("%-20s", $name)); }
	}else {	 
		#display cost captured and current sum for this line
		p(sprintf ("%5d: Cost: \$%5.02f | Sum: \$%5.02f", $pkg_count, $cost, $sum)); 
	}
  } 
  return ($pkg_count,$sum);
}#end processFile

 #display data controllers
sub p($){ return if ($opt{c} or $opt{p}); print "$_[0]\n"; pt($_[0]);}   #print to screen
sub pt($){ print $TEMP "$_[0]" . NL; } 						 			 #print to temp file
sub d($@){ my ($msg, @data) = @_; p("$msg: " . NL . Data::Dumper->Dump([\@data])); } #DumpData arg: $msg, @arrayToDump

sub cmdlnParm(){						#display the program usage info
 use Getopt::Std; 
   getopts( OPTIONS, \%opt );
   usage() if ($#ARGV<0 or $opt{h});
 
 my @rIndex;							#removeIndex locations of any bad files found
   if ($opt{d}) { d("Checking for files...", @ARGV);}
   elsif($opt{v}){ p("Checking for files...");}
   
   for my $i (0..$#ARGV){				#find unsupported files for @rIndex
	 #if the file exists, is readable, & is a plan-text file that is not empty,
	 #then display the valid filename, otherwise display warning
	 if (!(-f $ARGV[$i] && -s $ARGV[$i] && -r $ARGV[$i] && $ARGV[$i]=~m/\.txt$/)){
		$rIndex[++$#rIndex]=$i;
		p( "->Warning: Unsupported Text File $ARGV[$i]\n" ) if ($opt{v} or $opt{d});
	 }else { p( "->" . $ARGV[$i] . "\n")  if ($opt{v} or $opt{d}); }
   }
   
   if( scalar @rIndex ){ #if >0 there are unsupported files
	  #prune index places from the top of the stack down
	  for (reverse(@rIndex)){ my @ARGV = splice(@ARGV, $_, 1); }
	  if ($opt{d}){ 
	 	 d("\@rIndex file locations to remove", @rIndex);
		 d("\@ARGV Filtered",@ARGV);
	  }
   }

  (scalar (@ARGV) <=0) ? usage(): return; #condition ? if-true-return-this : else-return-this
} #end cmdLnParm

sub usage(){  #explain how to use the program
my ($app, $file, $copyleft, $v)=(APPNAME, FILENAME, COPYLEFT, VERSION);
print <<EOD;

Name: $app - $copyleft
Version: $v by Jason Campisi
License: GPL 2 or higher - gnu.org/licenses/gpl.html

Purpose: 
Read the FedEx EndOfDay Report file, capture and sum the cost of each 
parcel that is shipped, and provide a total package count & cost of shipping FedEx, 
so you do not have to manually add it.

How to use this program: 
Method 1) simply drag the report-file(s) onto the $file file 
          or shortcut and let go of it. It will handle the rest for you.
Method 2) run from cmd or powershell


NOTE: If the format of FedEx Report changes, then the pattern-matching code 
      might need to be tweaked. Use Debug-mode (-d) to track down problems

Usage: 
	$file options files
	$file -tv fedex-report.txt fedex-report2.txt
	$file -cp fedex-report2.txt

Default: all results are sent to the default printer via notepad

Options:
		 -h		Help

		 -v		Verbose data - sends to printer

		 -t		Terminal display only, while creating a
				temporary report file - no printing

		 -n		No auto-printing, only open report in notepad

		 -c		Cost total is only displayed - no printing
		 		This works alone or combined with option -p

		 -p		Parcel total is only displayed - no printing
		 		This works alone or combined with option -c
		 
		 -r		Recipient's name - sends to printer
				Combined with -f will disables the display of the 
				line-by-line breakdown of the cost & sum breakdown
		 
		 -f		Find tracking numbers - sends to printer
				Combined with -r will disables the display of the 
				line-by-line breakdown of the cost & sum breakdown

		 -d		Debug-mode to see how things have changed, 
				before tweaking cost-capture code
				Sends to printer, unless combined with a 
				none-printing option

EOD

 exit;
} #end usage

main();		#start program

__END__
