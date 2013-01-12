
## Introduction 

**Current version is 0.0.1 but it is pretty usable**. This project uses [semantic versioning](http://semver.org/).

This package provides some command-line utilities for inspecting processes' status on a server:

* `jsps`: wrapper for the `ps` utility that produces a `json` array with processes' info. It is based on [Mike Grundy's `awkward` script](https://github.com/mgrundy/awkward).

* `proc`: REST server that polls periodically `jsps` and exports process information in `json` format. The following routes are supported:

    * `/proc`                     get all `jsps` output
    * `/proc/:key`                returns the value of `key` for all processes (in a list)
    * `/proc/:key/:value`         returns a json object for the process that has `key`=`value`
    * `/proc/:key/:value/:proj`   as above, but projects the result onto field `proj`   

* `eps`: simple program that reorders the output of `jsps` by using fuzzy string matching on command name and user name (if available). To be used by piping the output of `jsps`.

## Installation ##

The usual suspect:

    > npm install procjs
    
## Usage ##

`jsps` can be used with all the usual `ps` options (that depend, in turn, on your OS):

    jsps -fec
    [{
      "UID": 0,
      "PID": 1,
      "PPID": 0,
      "C": 0,
      "STIME": "10:08AM",
      "TTY": "??",
      "TIME": "0:30.02",
      "CMD": "launchd"
    },
    {
      "UID": 0,
      "PID": 12,
      "PPID": 1,
      "C": 0,
      "STIME": "10:08AM",
      "TTY": "??",
      "TIME": "0:03.53",
      "CMD": "kextd"
    }
    ...
    
`eps` can be used to parse the output of `jsps` and may be given different *keywords* to be used for sorting the output. `eps` applies some similarity metrics (from module `stringsim`) to reorder and pretty print process information (in reverse order, so best matches are shown at the end of the list):

    > jsps -ec | eps 'core'
     ...
     74657      ??         1:55.34    DashboardClient
     280        ??         0:00.02    AirPort Base Station Agent 
     71058      ??         0:00.56    cookied   
     268        ??         0:00.05    filecoordinationd
     15         ??         0:44.91    opendirectoryd
     261        ??         0:00.92    com.apple.dock.extra
     29         ??         1:01.50    coreservicesd
     73686      ??         3:06.89    Cornerstone
     200        ??         0:13.97    coreaudiod
    > _
      

The similarity is computed by considering `CMD` and `USER` fields. I plan to introduce some simple customizable option to modify the fuzzy search.

`proc` can be started without options. It reads `settings.js` to setup some variables (like `jsps` options, refresh period and port to listen to). Here are some examples:

Getting the complete process list on the server:

    > curl localhost:6969/proc 
    [{
      "UID": 0,
      "PID": 1,
      "PPID": 0,
      "C": 0,
      "STIME": "10:08AM",
      "TTY": "??",
      "TIME": "0:30.02",
      "CMD": "launchd"
    },
    {
      "UID": 0,
      "PID": 12,
      "PPID": 1,
      "C": 0,
      "STIME": "10:08AM",
      "TTY": "??",
      "TIME": "0:03.53",
      "CMD": "kextd"
    }
    ...

Getting the information about a single process:

    > curl localhost:6969/proc/pid/12

or

    > curl localhost:6969/proc/cmd/kextd

both return a list with the same process description:

    [ {
      "UID": 0,
      "PID": 12,
      "PPID": 1,
      "C": 0,
      "STIME": "10:08AM",
      "TTY": "??",
      "TIME": "0:03.53",
      "CMD": "kextd"
    } ]

the process description can be projected to one of the available properties, e.g. (only the property of the first match is returned):

    > curl localhost:6969/proc/pid/12/CMD
    kextd

Finally, there is an additional attribute that can be queried, called `status`. This attribute can be used for determining if the process is UP or DOWN. It can be used to connect [Status Dashboard](https://github.com/obazoud/statusdashboard) to probe and display the status of processes on a remote server.


## Todo ##

* Extend Custom settings file.
* Enhanced `eps` output (use graphics symbols).
* Would it be nice to start processes with POST and kill process with DELETE
