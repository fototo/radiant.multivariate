## Resubmission

This is a resubmission (0.8.0). In this version I have fixed several bugs and added 
several new features (see NEWS.md for details).

Please note that this version addresses the reverse dependency check warnings from radiant.data for radiant.multivariate. Deprecating the `*_each` commands used in the 0.6.0 versions of the `radiant.*` packages is related to the deprecation of the `*_each` functions in dplyr. I will update the remaining `radiant` package asap after radiant.multivariate is available on CRAN.

## Test environments

* local OS X install, R 3.4
* local Windows install, R 3.4
* ubuntu 14.04 (on travis-ci), R 3.3.3 and R-dev
* win-builder (release)

## R CMD check results

There were no ERRORs or WARNINGs. There was one NOTE about a possibly mis-spelled word ("Analytics"). The spelling is correct however.

## Previous cran-comments

## Resubmission

This is a resubmission. In this version I have:

* Fixed an invalid URL README.md (i.e., https://www.r-project.org.org to  https://www.r-project.org

## Resubmission

This is a resubmission. In this version I have:

* Updated a link to https://tldrlegal.com/license/gnu-affero-general-public-license-v3-(agpl-3.0) to fix a libcurl error. I prefer to keep this link in the README.md file because it provides a convenient summary of the terms of the AGPL3 license.
* Added a link to  https://www.r-project.org/Licenses/AGPL-3 in the LICENSE file.

## Test environments
* local OS X install, R 3.3.1
* local Windows install, R 3.3.1
* ubuntu 12.04 (on travis-ci), R 3.3.1
* win-builder (devel and release)

## R CMD check results
There were no ERRORs or WARNINGs.

There was 1 NOTE: New submission
