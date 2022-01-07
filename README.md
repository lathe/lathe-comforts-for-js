# Lathe Comforts for JS

Lathe Comforts for JS is a collection of utilities that are handy for writing JavaScript code for browser and Node.js targets.

Lathe Comforts for JS is currently unstable and undocumented. Furthermore, many of these utilities are likely redundant due to improvements that have taken place in the JavaScript ecosystem since they were originally created.


## Features

Most of the utilities are all in one file, js/lathe.js. These began with ports of various utilities from the Arc version of Lathe (now called [Framewarc](https://github.com/rocketnia/framewarc)), but they soon took on a life of their own to include additional utilities for iframe manipulation and binary encodings.

The file js/lathe-fs.js includes some utilities for easier filesystem access in Node.js.

The file js/chops.js contains an engine for string-based interpreted languages, like macro systems and templating engines.

The file js/choppascript.js is a particular Chops DSL for generating JavaScript code. Its most useful feature is a `[str ...]` macro for writing multi-line strings.


## Setup

Lathe Comforts for JS is made up of unminified files that can be copied and pasted into a project as needed. These files will all work in Node.js, and everything but lathe-fs.js will work in the browser as well.

There's currently no npm package for these libraries.
