## Notes

**resubmission 3**

>several of the examples are still wrapped in \dontrun{}
please replace with if(interactive()),
or \donttest{} for lengthy examples (> 5s).

There are no instances of `\dontrun` in the previous submission, so I am resubmitting with no changes.  All examples output either `htmlwidgets` or `shiny` which require `interactive`, so everything is enclosed with `if(interactive())`.  Sorry if I am misunderstanding.

**resubmission 2**

use `if(interactive())` instead of `dontrun` in examples

**resubmission**

> This cannot work: The whole package must be licensed as is with a single 
license. You have to choose a license that is compatible with the 
licenses of each part and if required, get permission to relicense from 
the corresponding copyright holders of the diverse parts.
If this is still MIT in the end, then only ship the CRAN template for 
the MIT license as file LICENSE.
Please fix and resubmit.

use traditional MIT license


## Test environments
* local Windows 10 install, R 3.4.3
* ubuntu 14.04 (on travis-ci), R 3.4.3
* win-builder (devel and release)
* rhub check_for_cran()

## R CMD check results

0 errors | 0 warnings | 1 note

* This is a new release.
