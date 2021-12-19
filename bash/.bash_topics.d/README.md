## README

This directory holds "topic files".  Each topic file contains aliases, functions, and variable declarations specific to a single tool or facility.  One of the very first things `.bashrc` does is to source every `*.bash` file in this directory.  Files starting with `~` are ignored.  That's an easy way to "turn off" a topic temporarily.  It's important that these files run early so their contents are available to the rest of `.bashrc`, e.g., for use in the prompt, et al.  Files named `*.local-only.bash` are ignored by Git in this directory.  See the description of why I use a local-only branch in the top-level `README.md`.