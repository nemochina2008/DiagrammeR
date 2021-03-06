% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/get_edge_df_ws.R
\name{get_edge_df_ws}
\alias{get_edge_df_ws}
\title{Get the graph's edf filtered by a selection of edges}
\usage{
get_edge_df_ws(graph)
}
\arguments{
\item{graph}{a graph object of class
\code{dgr_graph}.}
}
\value{
an edge data frame.
}
\description{
From a graph object of class
\code{dgr_graph}, get the graph's internal
edge data frame that is filtered by the edge
ID values currently active as a selection.
}
\examples{
# Create a random graph using the
# `add_gnm_graph()` function
graph <-
  create_graph() \%>\%
  add_gnm_graph(
    n = 4,
    m = 4,
    set_seed = 23) \%>\%
  set_edge_attrs(
    edge_attr = value,
    values = c(2.5, 8.2, 4.2, 2.4))

# Select edges with ID values
# `1` and `3`
graph <-
  graph \%>\%
  select_edges_by_edge_id(
    edges = c(1, 3))

# Get the edge data frame that's
# limited to the rows that correspond
# to the edge selection
graph \%>\%
  get_edge_df_ws()
#>   id from to  rel value
#> 1  1    2  1 <NA>   2.5
#> 2  3    3  2 <NA>   4.2
}
