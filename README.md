noflo-xpress
============

[![Build Status](https://travis-ci.org/noflo/noflo-xpress.svg?branch=master)](https://travis-ci.org/noflo/noflo-xpress)

High-level Express.js components for NoFlo

## Changelog

#### 0.3.0
 - using process api in components & test_components
 - components/Router does not store state, components/Server saves server as scoped state for shutdown()
 - using noflo 0.8
 - only 1 router for everything, removed lib/
 - bumped express, uuid, and mocha dependencies
 - testing on 4.x and 6.x on Travis

#### 0.2.2
 - bumped chai, noflo, and mocha dependencies

#### 0.2.1

 - `req.uuid` and `res.uuid` are set by routers before applying filters, so
 request id is now available in filters as well as in downstream processes.

#### 0.2.0

 - Split `Router` into 4 components with different inports: `Router`,
 `PathRouter`, `FilterRouter` and `ComboRouter`. No meta ports configuration
 anymore as it is not supported by Flowhub.
 - `FILTER` port of type `function` is now `FILTERS` of type `array of function`
 which allows chaining multiple filters.
 - Remove obsolete `Route` component, use routers instead.
 - Remove unused `ROUTER` outport from routers.
