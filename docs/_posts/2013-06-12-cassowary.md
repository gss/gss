---
layout: doc
title: Cassowary
source: "https://github.com/slightlyoff/cassowary.js"
tag: cassowary
---
[Cassowary](http://www.cs.washington.edu/research/constraints/cassowary/) is a constraint solving toolkit that GSS uses for solving the correct sizes and positions for the various elements.

### Cassowary-DOM Connection

As with the [Badros and Borning's SCWM](http://www.jeffreynichols.com/papers/scwm-aaai.pdf), to connect the Cassowary constraint solver to UI objects, or in our case the DOM elements, each UI object has four constrainable variables of the class `c.Variable`:

`x`, `y`, `width`, `height`

These four constraint variables are instantiated and cached per UI object.  The other constraint relevant 'variables' available per UI object are actually constraint expressions of the class `c.Expression`, these include:

`centerX`, `centerY`, `right`, `bottom`

These constraint expressions are exposed like variables, but unlike constraint variables, each get returns a new instance of the expression.
