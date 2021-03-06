% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/rflow_management.R
\name{nodes_from_toml}
\alias{nodes_from_toml}
\title{load DAG's objects' definition from TOML files}
\usage{
nodes_from_toml(path, modified_since = NULL, verbose = TRUE)
}
\arguments{
\item{path}{path to folder with node definitions}

\item{modified_since}{a datetime object to keep only newly modified files}

\item{verbose}{logical; print verbose output?}
}
\description{
load DAG's objects' definition from TOML files
}
