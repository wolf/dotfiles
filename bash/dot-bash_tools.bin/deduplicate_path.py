#!/usr/bin/env -S uv run --script

import os

original_path = os.getenv("PATH")
output_elements = []
output_path = ""

if original_path is not None:
    path_elements = original_path.split(":")
    already_present = set()
    for directory in path_elements:
        if directory not in already_present:
            output_elements.append(directory)
            already_present.add(directory)
    output_path = ":".join(output_elements[1:])  # Trim the path added by `uv` just to run this script
else:
    output_path = original_path

print(f'export PATH="{output_path}"')
