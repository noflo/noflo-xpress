noflo-xpress
============

High-level Express.js components for NoFlo

## Changelog

#### 0.2.0

 - Split `Router` into 4 components with different inports: `Router`,
 `PathRouter`, `FilterRouter` and `ComboRouter`. No meta ports configuration
 anymore as it is not supported by Flowhub.
 - `FILTER` port of type `function` is now `FILTERS` of type `array of function`
 which allows chaining multiple filters.
 - Remove obsolete `Route` component, use routers instead.
 - Remove unused `ROUTER` outport from routers.
