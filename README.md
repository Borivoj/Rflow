
<!-- README.md is generated from README.Rmd. Please edit that file -->

# Rflow

Rflow is an R package providing R users a general-purpose workflow
system.

## Installation

…

## Examples

…

## TODO:

**Features**

  - R/SQL code in standalone R scripts (outside of TOML file)
  - more nuanced `verbose` option
  - logging into rflow object
  - handling of obsolete nodes
      - removing objects from DAG
      - removing cache
      - removing node config files
      - deleting represented objects
  - deleting properties / setting some to NULL
      - currently, if a property is deleted update() method ignores it
  - query function to set or get fields of multiple objects
  - documentation
  - quick start guide
  - allow Python and Julia code
  - new node types:
      - test node
  - Rflow manager as a Shiny app

**Implementation**

  - experiment with proper ORM instead of serialization of selected
    properties
  - SQL execution by a generic R function instead of metaprogramming
      - solves potential problems with escaping quotes in SQL code
  - environments as R6 classes
  - generic methods in node class for initializing and updating
    properties
  - more unit tests
  - make all public properties active (trigger persistence storage)
