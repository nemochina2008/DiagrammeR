#' Get the authority scores for nodes in the graph
#' @description Get the Kleinberg authority centrality
#' scores for all nodes in the graph.
#' @param graph a graph object of class
#' \code{dgr_graph}.
#' @param weights_attr an optional name of the edge
#' attribute to use in the adjacency matrix. If
#' \code{NULL} then, if it exists, the \code{weight}
#' edge attribute of the graph will be used.
#' @return a data frame with authority scores for
#' each of the nodes.
#' @examples
#' # Create a random graph using the
#' # `add_gnm_graph()` function
#' graph <-
#'   create_graph() %>%
#'   add_gnm_graph(
#'     n = 10,
#'     m = 15,
#'     set_seed = 23)
#'
#' # Get the authority centrality scores
#' # for all nodes in the graph
#' get_authority_centrality(graph)
#' #>    id authority_centrality
#' #> 1   1            0.6950912
#' #> 2   2            0.6176471
#' #> 3   3            0.0000000
#' #> 4   4            0.0000000
#' #> 5   5            0.3674279
#' #> 6   6            0.3157923
#' #> 7   7            0.4982552
#' #> 8   8            1.0000000
#' #> 9   9            0.1824629
#' #> 10 10            0.6176471
#'
#' # Add the authority centrality
#' # scores to the graph as a node
#' # attribute
#' graph <-
#'   graph %>%
#'   join_node_attrs(
#'     df = get_authority_centrality(.))
#'
#' # Display the graph's node data frame
#' get_node_df(graph)
#' #>    id type label authority_centrality
#' #> 1   1 <NA>  <NA>            0.6950912
#' #> 2   2 <NA>  <NA>            0.6176471
#' #> 3   3 <NA>  <NA>            0.0000000
#' #> 4   4 <NA>  <NA>            0.0000000
#' #> 5   5 <NA>  <NA>            0.3674279
#' #> 6   6 <NA>  <NA>            0.3157923
#' #> 7   7 <NA>  <NA>            0.4982552
#' #> 8   8 <NA>  <NA>            1.0000000
#' #> 9   9 <NA>  <NA>            0.1824629
#' #> 10 10 <NA>  <NA>            0.6176471
#' @importFrom igraph authority_score
#' @export get_authority_centrality

get_authority_centrality <- function(graph,
                                     weights_attr = NULL) {

  # Validation: Graph object is valid
  if (graph_object_valid(graph) == FALSE) {
    stop("The graph object is not valid.")
  }

  # Convert the graph to an igraph object
  ig_graph <- to_igraph(graph)

  if (!is.null(weights_attr)) {

    if (inherits(weights_attr, "character")) {

      # Stop function if the edge attribute does not exist
      if (!(weights_attr %in% colnames(graph$edges_df))) {
        stop("The edge attribute to be used as weights does not exist in the graph.")
      }

      # Stop function if the edge attribute is not numeric
      if (!is.numeric(graph$edges_df[, which(colnames(graph$edges_df) == weights_attr)])) {
        stop("The edge attribute to be used as weights is not numeric.")
      }

      weights_attr <- graph$edges_df[, which(colnames(graph$edges_df) == weights_attr)]
    }
  }

  # Get the authority centrality values for
  # each of the graph's nodes
  authority_centrality_values <-
    igraph::authority_score(
      graph = ig_graph,
      weights = weights_attr)

  # Create df with authority centrality values
  data.frame(
    id = authority_centrality_values$vector %>%
      names() %>%
      as.integer(),
    authority_centrality = unname(authority_centrality_values$vector),
    stringsAsFactors = FALSE)
}
