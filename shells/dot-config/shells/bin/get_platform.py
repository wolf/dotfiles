#!/usr/bin/env -S uv run --quiet --script
"""
Platform detection utility module.

This module provides functionality to detect the current operating system
platform with special handling for Windows subsystems and WSL.
"""

import os
import platform
import re
import subprocess
from typing import Optional


def get_platform() -> str:
    """
    Detect the current operating system platform.

    Returns a normalized platform name with special handling for:
    - MinGW environments (returns 'mingw')
    - Cygwin environments (returns 'cygwin')
    - WSL2 environments (returns 'wsl')
    - Standard platforms (returns lowercase platform name)

    Returns
    -------
    str
        The detected platform name in lowercase.

    Examples
    --------
    >>> get_platform()  # On Linux
    'linux'
    >>> get_platform()  # On WSL2
    'wsl'
    >>> get_platform()  # On Windows with MinGW, e.g., Git Bash for Windows
    'mingw'
    >>> get_platform()  # On macOS
    'darwin'
    """
    # Check environment variables first (for Git Bash/MinGW detection)
    msystem = os.environ.get("MSYSTEM", "").lower()
    if msystem.startswith("mingw") or "mingw" in os.environ.get("MSYSTEM_CHOST", "").lower():
        return "mingw"

    # Check for Cygwin environment
    if "CYGWIN" in os.environ or os.environ.get("TERM", "").startswith("cygwin"):
        return "cygwin"

    uname = platform.system().lower()

    # Check for MinGW (may be extraneous)
    if re.match(r"mingw.*", uname):
        return "mingw"

    # Check for Cygwin (may be extraneous)
    if re.match(r"cygwin.*", uname):
        return "cygwin"

    # Check for WSL2 on Linux
    if uname == "linux":
        kernel_release = _get_kernel_release()
        if kernel_release and "wsl2" in kernel_release.lower():
            return "wsl"

    return uname


def _get_kernel_release() -> Optional[str]:
    """
    Get the kernel release string, equivalent to 'uname -r'.

    Returns
    -------
    Optional[str]
        The kernel release string, or None if unable to retrieve.
    """
    try:
        result = subprocess.run(["uname", "-r"], capture_output=True, text=True, check=True)
        return result.stdout.strip()
    except (subprocess.CalledProcessError, FileNotFoundError):
        return None


if __name__ == "__main__":
    print(get_platform())
