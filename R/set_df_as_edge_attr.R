#' Set a data frame as an edge attribute
#' @description From a graph object of class
#' \code{dgr_graph}, bind a data frame as an edge
#' attribute property for one given graph edge. The
#' data frames are stored in list columns within
#' a \code{df_tbl} object, itself residing within
#' the graph object. A \code{df_id} value is
#' generated and serves as a pointer to the table
#' row that contains the ingested data frame.
#' @param graph a graph object of class
#' \code{dgr_graph}.
#' @param edge the edge ID to which the data frame
#' will be bound as an attribute.
#' @param df the data frame to be bound to the
#' edge as an attribute.
#' @return a graph object of class \code{dgr_graph}.
#' @examples
#' # Create a node data frame (ndf)
#' ndf <-
#'   create_node_df(
#'     n = 4,
#'     type = "basic",
#'     label = TRUE,
#'     value = c(3.5, 2.6, 9.4, 2.7))
#'
#' # Create an edge data frame (edf)
#' edf <-
#'   create_edge_df(
#'     from = c(1, 2, 3),
#'     to = c(4, 3, 1),
#'     rel = "leading_to")
#'
#' # Create a graph
#' graph <-
#'   create_graph(
#'     nodes_df = ndf,
#'     edges_df = edf)
#'
#' # Create a simple data frame to add as
#' # an edge attribute
#' df <-
#'   data.frame(
#'     a = c("one", "two", "three"),
#'     b = c(1, 2, 3),
#'     stringsAsFactors = FALSE)
#'
#' # Bind the data frame as an edge attribute
#' # to the edge with ID `1`
#' graph <-
#'   set_df_as_edge_attr(
#'     graph = graph,
#'     edge = 1,
#'     df = df)
#' @importFrom dplyr filter everything mutate select bind_rows
#' @importFrom tibble tibble as_tibble
#' @importFrom purrr flatten_chr
#' @export set_df_as_edge_attr

set_df_as_edge_attr <- function(graph,
                                edge,
                                df) {

  # Get the time of function start
  time_function_start <- Sys.time()

  # Validation: Graph object is valid
  if (graph_object_valid(graph) == FALSE) {
    stop("The graph object is not valid.")
  }

  # Validation: Graph contains edges
  if (graph_contains_edges(graph) == FALSE) {
    stop("The graph contains no edges, so, a df cannot be added.")
  }

  # Value given for edge must only be a single value
  if (length(edge) > 1) {
    stop("Only one edge can be specified.")
  }

  # Values given for edge must correspond to an edge ID
  # in the graph
  if (!(edge %in% graph$edges_df$id)) {
    stop("The value given for `edge` does not correspond to an edge ID.")
  }

  # Create bindings for specific variables
  df_id__ <- node_edge__ <- id__ <- NULL

  # Generate an empty `df_storage` list if not present
  # TODO: put this in `create_graph()`
  if (is.null(graph$df_storage)) {
    graph$df_storage <- list()
  }

  # Generate a random 8-character, alphanumeric
  # string to use as a data frame ID (`df_id`)
  df_id <-
    replicate(
      8, sample(c(LETTERS, letters, 0:9), 1)) %>%
    paste(collapse = "")

  # Mutate the incoming data frame to contain
  # identifying information
  df <-
    df %>%
    dplyr::mutate(
      df_id__ = df_id,
      node_edge__ = "edge",
      id__ = edge) %>%
    dplyr::select(df_id__, node_edge__, id__, everything()) %>%
    tibble::as_tibble()

  # If there is an existing data frame attributed
  # to the edge, remove it
  if (dplyr::bind_rows(graph$df_storage) %>%
      dplyr::filter(node_edge__ == "edge") %>%
      dplyr::filter(id__ == edge) %>%
      nrow() > 0) {

    df_object_old <-
      (dplyr::bind_rows(graph$df_storage) %>%
         dplyr::filter(node_edge__ == "edge") %>%
         dplyr::filter(id__ == edge) %>%
         dplyr::select(df_id__) %>%
         purrr::flatten_chr())[1]

    graph$df_storage[[df_object_old]] <- NULL
  }

  # Bind the data frame to `df_storage` list component
  graph$df_storage[[`df_id`]] <- df

  # Set the `df_id` edge attribute using the
  # `set_edge_attrs()` function
  graph <-
    set_edge_attrs(
      x = graph,
      edge_attr = "df_id",
      values = df_id,
      from = graph$edges_df[which(graph$edges_df[, 1] == edge), 2],
      to = graph$edges_df[which(graph$edges_df[, 1] == edge), 3])

  # Update the `graph_log` df with an action
  graph$graph_log <-
    graph$graph_log[-nrow(graph$graph_log),] %>%
    add_action_to_log(
      version_id = nrow(graph$graph_log) + 1,
      function_used = "set_df_as_edge_attr",
      time_modified = time_function_start,
      duration = graph_function_duration(time_function_start),
      nodes = nrow(graph$nodes_df),
      edges = nrow(graph$edges_df))

  # Write graph backup if the option is set
  if (graph$graph_info$write_backups) {
    save_graph_as_rds(graph = graph)
  }

  graph
}
