
<!-- README.md is generated from README.Rmd. Please edit that file -->

# ustfd

<!-- badges: start -->
<!-- badges: end -->

The goal of ustfd is to make it easier to interact with the US Treasury
Fiscal Data API.

## Installation

You can install the development version of ustfd from
[GitHub](https://github.com/) with:

``` r
# install.packages("devtools")
devtools::install_github("groditi/ustfd")
```

## Getting Started

`ustfd` provides functions for retrieving and processing data from the
Fiscal Data API. There is 4 steps to the workflow:

-   form a query using `ustfd_query`
-   make an API request using `ustfd_request`
-   extract metadata about the results using
    `ustfd_response_meta_object`
-   extract the payload of the response using `ustfd_response_payload`

The function `ustfd_simple` aggregates all 4 steps into a single
function call and should cover most use cases. Dealing with pagination
is left to the user.

A list of supported endpoints can be retrieved with `ustfd_endpoints`
and a dictionary of fields available for each endpoint can be retrieved
with `ustfd_field_dictionary`.

## Example

This is a basic example which shows you how to retrieve data:

``` r
 library(ustfd)
 library(dplyr)
#> Warning: package 'dplyr' was built under R version 4.0.5
#> 
#> Attaching package: 'dplyr'
#> The following objects are masked from 'package:stats':
#> 
#>     filter, lag
#> The following objects are masked from 'package:base':
#> 
#>     intersect, setdiff, setequal, union

 interest_rates <- ustfd_simple(
   '/v2/accounting/od/avg_interest_rates',
    fields = c(
     'record_date', 'security_desc','security_type_desc','avg_interest_rate_amt'
    ),
    filter = list(
      record_date = c('=' = '2020-03-31')
    ),
   page_size = 100
 )
 
 select(interest_rates$data, -record_date)
#> # A tibble: 16 x 3
#>    security_desc                               security_type_d~ avg_interest_ra~
#>    <chr>                                       <chr>                       <dbl>
#>  1 Treasury Bills                              Marketable                0.0122 
#>  2 Treasury Notes                              Marketable                0.0210 
#>  3 Treasury Bonds                              Marketable                0.0378 
#>  4 Treasury Inflation-Protected Securities (T~ Marketable                0.00741
#>  5 Treasury Floating Rate Note (FRN)           Marketable                0.00148
#>  6 Federal Financing Bank                      Marketable                0.0268 
#>  7 Total Marketable                            Marketable                0.0221 
#>  8 Domestic Series                             Non-marketable            0.0804 
#>  9 Foreign Series                              Non-marketable            0.0731 
#> 10 State and Local Government Series           Non-marketable            0.0180 
#> 11 United States Savings Securities            Non-marketable            0.0304 
#> 12 United States Savings Inflation Securities  Non-marketable            0.0361 
#> 13 Government Account Series                   Non-marketable            0.0248 
#> 14 Government Account Series Inflation Securi~ Non-marketable            0.0130 
#> 15 Total Non-marketable                        Non-marketable            0.0250 
#> 16 Total Interest-bearing Debt                 Interest-bearin~          0.0229
```

An example of how to use the field dictionaries:

``` r
 library(ustfd)
 ustfd_field_dictionary('/v2/accounting/od/avg_interest_rates')
#> # A tibble: 11 x 4
#>    field_name              label                        data_type  data_format
#>    <chr>                   <chr>                        <chr>      <chr>      
#>  1 record_date             Record Date                  DATE       YYYY-MM-DD 
#>  2 security_type_desc      Security Type Description    STRING     String     
#>  3 security_desc           Security Description         STRING     String     
#>  4 avg_interest_rate_amt   Average Interest Rate Amount PERCENTAGE 10.2%      
#>  5 src_line_nbr            Source Line Number           NUMBER     10.2       
#>  6 record_fiscal_year      Fiscal Year                  YEAR       YYYY       
#>  7 record_fiscal_quarter   Fiscal Quarter Number        QUARTER    Q          
#>  8 record_calendar_year    Calendar Year                YEAR       YYYY       
#>  9 record_calendar_quarter Calendar Quarter Number      QUARTER    Q          
#> 10 record_calendar_month   Calendar Month Number        MONTH      MM         
#> 11 record_calendar_day     Calendar Day Number          DAY        DD
```
