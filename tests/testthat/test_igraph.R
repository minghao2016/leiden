library("leiden")
library("reticulate")
library("igraph")
context("running Leiden on an igraph object")
set.seed(9000)

adj_mat <- matrix(round(runif(10000, 0, 1)), 100, 100)
snn_graph <- graph_from_adjacency_matrix(adj_mat)

modules <- reticulate::py_module_available("leidenalg") && reticulate::py_module_available("igraph")

skip_if_no_python <- function() {
  if (!modules)
    testthat::skip("leidenalg not available for testing")
}


test_that("run with defaults", {
  skip_if_no_python()
  partition <- leiden(snn_graph)
  expect_length(partition, 100)
})

test_that("run with ModularityVertexPartition", {
  skip_if_no_python()
  partition <- leiden(snn_graph, partition_type = "ModularityVertexPartition")
  expect_length(partition, 100)
})

test_that("run with resolution parameter", {
  skip_if_no_python()
  partition <- leiden(snn_graph, resolution_parameter = 0.95)
  expect_length(partition, 100)
})

test_that("run with max_comm_size", {
  skip_if_no_python()
  partition <- leiden(snn_graph,
                      partition_type = "ModularityVertexPartition",
                      resolution_parameter = 0.2,
                      max_comm_size = 8,
                      degree_as_node_size = TRUE,
                      seed = 9001)
  expect_length(partition, length(V(snn_graph)))
  expect_equal(sort(unique(partition)), 1:13)
  expect_equal(max(table(partition)), 8)
})

test_that("run on igraph object with random seed", {
  skip_if_no_python()
  partition <- leiden(snn_graph, seed = 42L, weights = NULL)
  expect_length(partition, 100)
  # test if gives same output with same seed
  expect_identical(leiden(snn_graph, seed = 42L, weights = NULL),
                    leiden(snn_graph, seed = 42L, weights = NULL))
})

weights <- sample(1:10, sum(adj_mat!=0), replace=TRUE)

test_that("run with non-wieghted igraph object and weights vector", {
  skip_if_no_python()
  partition <- leiden(snn_graph, weights = weights)
  expect_length(partition, 100)
})

adj_mat <- ifelse(adj_mat == 1, weights, 0)
snn_graph <- graph_from_adjacency_matrix(adj_mat, weighted = TRUE)

test_that("run with wieghted igraph object", {
  skip_if_no_python()
  partition <- leiden(snn_graph)
  expect_length(partition, 100)
})

rownames(adj_mat) <- 1:nrow(adj_mat)
colnames(adj_mat) <- 1:ncol(adj_mat)

test_that("run with named adjacency matrix", {
  skip_if_no_python()
  partition <- leiden(snn_graph)
  expect_length(partition, 100)
})
