% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/ustfd_query.R
\name{ustfd_query}
\alias{ustfd_query}
\title{Form a Query}
\usage{
ustfd_query(
  endpoint,
  filter = NULL,
  fields = NULL,
  sort = NULL,
  page_size = NULL,
  page_number = NULL
)
}
\arguments{
\item{endpoint}{required string representing an API endpoint}

\item{filter}{optional list used to subset the data. See \link{filter-syntax} for
more information.}

\item{fields}{optional character vector of the fields to be retrieved}

\item{sort}{optional string or character vector. Ordering defaults to
ascending, to specify descending order precede the field name with '-'}

\item{page_size}{optional integer for pagination}

\item{page_number}{optional integer for pagination}
}
\value{
a list
}
\description{
\code{ustfd_query()} will verify the endpoint is valid and return a list suitable
for passing to \code{\link[=ustfd_url]{ustfd_url()}} and \code{\link[=ustfd_request]{ustfd_request()}}.
}
\examples{

library(ustfd)
ustfd_query(
  'v2/accounting/od/utf_qtr_yields',
   filter = list(record_date = c('>=' = lubridate::today()-10))
)
ustfd_query(
  'v2/accounting/od/utf_qtr_yields',
   filter = list(record_date = list('in' = c('2020-03-15','2020-03-16','2020-03-17')))
)
ustfd_query(
  'v2/accounting/od/utf_qtr_yields',
   filter = list(record_date = c('=' = '2020-03-15'))
)



}
\seealso{
Other ustfd_user: 
\code{\link{endpoint_exists}()},
\code{\link{ustfd_all_pages}()},
\code{\link{ustfd_datasets}()},
\code{\link{ustfd_simple}()},
\code{\link{ustfd_table_columns}()},
\code{\link{ustfd_tables}()}
}
\concept{ustfd_user}
