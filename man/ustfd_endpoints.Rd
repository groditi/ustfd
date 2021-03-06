% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/ustfd_endpoints.R
\name{ustfd_endpoints}
\alias{ustfd_endpoints}
\title{Return a table of supported and known endpoints}
\source{
\url{https://fiscaldata.treasury.gov/api-documentation/#list-of-endpoints}
}
\usage{
ustfd_endpoints()
}
\value{
tibble
}
\description{
\code{ustfd_endpoints} provides details about 80 known endpoints for Fiscal Data.
A data frame with 80 rows and the following 4 columns:
\itemize{
\item \code{data_set} - name of the source data_set
\item \code{table_name} - Name of the table within the data set
\item \code{endpoint} - the serialized version of the URL endpoint (natural key)
\item \code{endpoint_description} - a description for the data in the endpoint
}
}
\examples{
library(ustfd)
unique(ustfd_endpoints()$data_set)



}
\seealso{
Other ustfd_user: 
\code{\link{ustfd_field_dictionary}()},
\code{\link{ustfd_query}()},
\code{\link{ustfd_simple}()}
}
\concept{ustfd_user}
