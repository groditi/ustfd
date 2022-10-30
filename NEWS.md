# ustfd 0.2.0

* Better error handling using `rlang`
* YEAR, QUARTER, MONTH, and DAY columns are treated as integers, not numeric
* PERCENTAGE columns no are no longer multiplied by 0.01. This change breaks
existing behavior but was absolutely necessary to do before anyone relied on it.
* Previously, a request that generated zero results would result in an error
* `ustfd_response_payload` now guarantees the return is a tibble with the 
correct number of columns in the correct types, even if a the request generates
no results. 

# ustfd 0.1.1

* Correct error in the `ustfd_field_dictionary()` documentation/example

# ustfd 0.1.0

* Initial release.
