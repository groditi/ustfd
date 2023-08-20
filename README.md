
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

A list of supported endpoints can be retrieved with `ustfd_tables` and a
dictionary of fields available for each endpoint can be retrieved with
`ustfd_table_columns`.

## Example

This is a basic example which shows how to retrieve data:

``` r
 library(ustfd)
 library(dplyr, warn.conflicts = FALSE)

 interest_rates <- ustfd_simple(
   'v2/accounting/od/avg_interest_rates',
    fields = c(
     'record_date', 'security_desc','security_type_desc','avg_interest_rate_amt'
    ),
    filter = list(
      record_date = c('=' = '2020-03-31')
    ),
   page_size = 20
 )
 
 select(interest_rates$data, -record_date)
#> # A tibble: 16 x 3
#>    security_desc                        security_type_desc avg_interest_rate_amt
#>    <chr>                                <chr>                              <dbl>
#>  1 Treasury Bills                       Marketable                         1.22 
#>  2 Treasury Notes                       Marketable                         2.10 
#>  3 Treasury Bonds                       Marketable                         3.78 
#>  4 Treasury Inflation-Protected Securi~ Marketable                         0.741
#>  5 Federal Financing Bank               Marketable                         2.68 
#>  6 Total Marketable                     Marketable                         2.21 
#>  7 Domestic Series                      Non-marketable                     8.04 
#>  8 Foreign Series                       Non-marketable                     7.31 
#>  9 State and Local Government Series    Non-marketable                     1.80 
#> 10 United States Savings Securities     Non-marketable                     3.04 
#> 11 United States Savings Inflation Sec~ Non-marketable                     3.61 
#> 12 Government Account Series            Non-marketable                     2.48 
#> 13 Government Account Series Inflation~ Non-marketable                     1.30 
#> 14 Total Non-marketable                 Non-marketable                     2.50 
#> 15 Total Interest-bearing Debt          Interest-bearing ~                 2.29 
#> 16 Treasury Floating Rate Notes (FRN)   Marketable                         0.148
```

An example of how to use the field dictionaries:

``` r
 library(ustfd)
 library(dplyr, warn.conflicts = FALSE)

 select(ustfd_table_columns('v2/accounting/od/avg_interest_rates'), -endpoint, -definition)
#> # A tibble: 11 x 4
#>    column_name             data_type  pretty_name                  is_required
#>    <chr>                   <chr>      <chr>                        <lgl>      
#>  1 record_date             DATE       Record Date                  TRUE       
#>  2 security_type_desc      STRING     Security Type Description    TRUE       
#>  3 security_desc           STRING     Security Description         TRUE       
#>  4 avg_interest_rate_amt   PERCENTAGE Average Interest Rate Amount FALSE      
#>  5 src_line_nbr            NUMBER     Source Line Number           TRUE       
#>  6 record_fiscal_year      YEAR       Fiscal Year                  TRUE       
#>  7 record_fiscal_quarter   QUARTER    Fiscal Quarter Number        TRUE       
#>  8 record_calendar_year    YEAR       Calendar Year                TRUE       
#>  9 record_calendar_quarter QUARTER    Calendar Quarter Number      TRUE       
#> 10 record_calendar_month   MONTH      Calendar Month Number        TRUE       
#> 11 record_calendar_day     DAY        Calendar Day Number          TRUE
```

An example of how to use multiple filters:

``` r
 library(ustfd)
 library(dplyr, warn.conflicts = FALSE)

 interest_rates <- ustfd_simple(
    'v2/accounting/od/avg_interest_rates',
    fields = c(
        'record_date', 'security_desc','security_type_desc','avg_interest_rate_amt'
    ),
    filter = list(
        record_date = c('>=' = '2020-03-31'),
        record_date = c('<=' = '2020-05-31'),
        security_type_desc = c('=' = 'Marketable'),
        avg_interest_rate_amt = c('>=' = 1.0)
    )
)
 
 select(interest_rates$data, -security_type_desc, rate = 'avg_interest_rate_amt')
#> # A tibble: 13 x 3
#>    record_date security_desc           rate
#>    <date>      <chr>                  <dbl>
#>  1 2020-03-31  Treasury Bills          1.22
#>  2 2020-03-31  Treasury Notes          2.10
#>  3 2020-03-31  Treasury Bonds          3.78
#>  4 2020-03-31  Federal Financing Bank  2.68
#>  5 2020-03-31  Total Marketable        2.21
#>  6 2020-04-30  Treasury Notes          2.07
#>  7 2020-04-30  Treasury Bonds          3.76
#>  8 2020-04-30  Total Marketable        1.96
#>  9 2020-04-30  Federal Financing Bank  2.68
#> 10 2020-05-31  Treasury Notes          2.04
#> 11 2020-05-31  Treasury Bonds          3.72
#> 12 2020-05-31  Federal Financing Bank  2.68
#> 13 2020-05-31  Total Marketable        1.84
```
