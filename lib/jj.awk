#!/bin/awk
function isnum(x){return(x==x+0)}
BEGIN {
    ORS = ""
    if (!header) {
        header=1
    }
}

# specify header on command line if you need something other than 1
NR < header {next}

{
    if (NR==header) {
        fields=NF
        for (i=1; i <= NF; i++) {
            headers[i] = $i
        }
    }
    else {
        print "{"
            for (i=1; i < fields; i++) {
                print "\""headers[i]"\": " 
                if (isnum($i)) {
                    print $i
                }
                else{
                    print "\"" $i "\""
            }
            print   ", "
        }

        print "\""headers[fields]"\": "

        if (NF==fields) {
            if (isnum($i)) {
                print $i
            }
            else {
                print "\"" $i "\""
            }
        }
        else {
            print "\""
            for (i=fields; i <=NF; i++) {
                print $i " "
            }
        print "\"" 
        }

    print "},\n"

    }
    fflush()
}
