FECTR:
=====
FedEx Cost-Total ReportReader is a windows droplet program that takes the Fedex's Desktop Ship Manager's "End of Day" report that was saved to text file, adds the shipping cost column for all the packages in the list and display the results of the total cost, then prints the report. Designed for users that can only understand dragging a report file onto a shortcut with settings pre-set and admins who prefer the command-line.

Requirements:
=====
    Strawberry Perl v5.X - http://strawberryperl.com
    Microsoft Windows XP or higher.

Usage: 
=====
Format

    fectr.cmd options file(s)

Examples

    fectr.cmd -tv fedex-report1.txt fedex-report2.txt
    fectr.cmd -cp fedex-report2.txt


Default:
=====
    1) FedEx Report files must by a text file that has a 'txt' file extension. 
    2) All results are sent to a terminal display & to the default printer via Notepad for a hard copy.

Options:
=====
    -h		Help
    -v		Verbose data, shows what is on the line that the cost was captured from - sends to printer
    -t		Terminal display only while creating temp log file - no printing
    -n		No auto-printing, but open report in notepad
    -c		Cost total is only displayed - no printing
    -p		Parcel total is only displayed - no printing
    -f		Find tracking numbers - sends to printer 
    		Combined with -r will disables the display of the line-by-line breakdown of the cost & sum
    -r		Recipient's name - sends to printer
    		Combined with -f will disables the display of the line-by-line breakdown of the cost & sum
    -d		Debug-mode to see how things have changed, before tweaking cost-capture code - Sends to printer
		 

Example I.
=====
Command

    fectr.cmd -fr "fedex cost report.txt"

Result

    Report Data File: C:\Users\Triple8\Desktop\fedex cost report.txt
    
    Shipping Info:
    948815860218486        DAVE TENNET         
    948815860218493        ROSE TYLER          
    948815860218509        C\O CAPTAIN JACK        
    948815860218516        MATT SMITH          
    948815860218523        CHRIS ECCLESTON     
    948815860218530        DONNA NOBLE         
    948815860218547        MARTHA JONES        
    948815860218554        THE DOCTOR          
    948815860218621        SHADOW PROCLAMATION 
	948815860218578        RORY WILLIAMS                   
    
    Total Parcel Count: 11
    Total Shipping Cost: $151.17
    
    -->This Report Has Been Sent To The Printer


Example II. 
=====
Command

    fectr.cmd -c "fedex cost report.txt"

Result

    151.17


Example III.
=====
Command

    fectr.cmd "fedex cost report.txt"

Result

    Report Data File: C:\Users\Triple8\Desktop\fedex cost report.txt
    
    Shipping Cost:
        1: Cost: $10.72 | Sum: $10.72
		2: Cost: $12.99 | Sum: $23.71
        3: Cost: $13.70 | Sum: $37.41
        4: Cost: $10.05 | Sum: $47.46
        5: Cost: $15.90 | Sum: $63.36
        6: Cost: $14.48 | Sum: $77.84
        7: Cost: $11.25 | Sum: $89.09
        8: Cost: $11.07 | Sum: $100.16
        9: Cost: $14.05 | Sum: $114.21
        10: Cost: $24.48 | Sum: $138.69
        11: Cost: $12.48 | Sum: $151.17
		
    Total Parcel Count: 11
    Total Shipping Cost: $151.17
    
    -->This Report Has Been Sent To The Printer


Example IV.
=====
Command

	fectr.cmd -tv "fedex cost report.txt"

Result

    Report Data File: C:\Users\Triple8\Desktop\fedex cost report.txt

    Shipping Cost:
    948815860218486  14.00  RH  C  10.72     DAVE TENNET                  72 Main St RD      CLIFTON    NJ 07013  Adult  
        1: Cost: $10.72 | Sum: $10.72
    948815860218493  14.00  RH  C  12.99     ROSE TYLER                   65 BAD WOLF ST     NORTH PALM FL 33408  Adult  
        2: Cost: $12.99 | Sum: $23.71
    948815860218509  4.00   RH  C  13.70     C\O CAPTAIN JACK                 25 EARTH STATION 	 BOCA RATON FL 33434  Adult  
        3: Cost: $13.70 | Sum: $37.41
    948815860218516  4.00   RH  C  10.05     MATT SMITH                   2 ANONYMOUS CT     RINGWOOD   NJ 07456  Adult  
        4: Cost: $10.05 | Sum: $47.46
    948815860218523  21.00  RG  C  15.90     CHRIS ECCLESTON      GALIFREY41 STERNS RD       AMHERST    NH 03031  Adult  
        5: Cost: $15.90 | Sum: $63.36
    948815860218530  21.00  RH  C  14.48     DONNA NOBLE                  88 KINSLEY AVE     MATAWAN    NJ 07747  Adult  
        6: Cost: $14.48 | Sum: $77.84
    948815860218547  21.00  RH  C  11.25     MARTHA JONES                 42 MICKEY LN       PALM BEACH FL 33480  Adult  
        7: Cost: $11.25 | Sum: $89.09
    948815860218554  21.00  RH  C  11.07     THE DOCTOR                   1 TARDIS CT        CHICAGO    IL 60622  Adult  
        8: Cost: $11.07 | Sum: $100.16
    948815860218561  19.00  RH  C  14.05     AMELIA POND                  8 WAITING ST    	 BOUND BROO NJ 08805  Adult  
        9: Cost: $14.05 | Sum: $114.21
    948815860218621  21.00  RG  C  24.48     SHADOW PROCLAMATION  A1      20 GALACTIC LAW CT NOLE POLE  AK 99705  Adult  
       10: Cost: $24.48 | Sum: $138.69
    948815860218578  21.00  RG  C  12.48     RORY WILLIAMS        12PM    100 NIGHT RD       CHARLOTTE  NC 28215  Adult  
       11: Cost: $12.48 | Sum: $151.17

    Total Parcel Count: 11
    Total Shipping Cost: $151.17	
