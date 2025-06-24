import platform
import re
from os import PathLike
from pathlib import PurePosixPath, PureWindowsPath


# Calculated once, when this module is imported
_is_windows = platform.system() == "Windows"
_consecutive_windows_slashes_pat = re.compile(r"\\+")
_consecutive_posix_slashes_pat = re.compile(r"/+")


def fix_path_separators(path: PathLike) -> PurePosixPath:
    broken_path = str(path)
    windows_slashes_fixed = re.sub(_consecutive_windows_slashes_pat, "/", broken_path)
    consecutive_posix_slashes_fixed = re.sub(_consecutive_posix_slashes_pat, "/", windows_slashes_fixed)
    return PurePosixPath(consecutive_posix_slashes_fixed)


def posix_path(path: PathLike | str) -> PurePosixPath:
    """
    Convert a platform-dependent string into a `pathlib.PurePosixPath`, formatted correctly

    Why is this hard?  Git Bash for Windows is the special case.  WSL acts exactly like any other Linux. It is not
    special.  I don't run any other Windows-specific Bash environments, so Git Bash for Windows is all I have to worry
    about.

    Here's the weird thing Git Bash for Windows does: within a Bash session, if you `echo $PATH`, you will what looks
    like a POSIX-style path.  It will have forward slashes, `/`.  Each path will be separated by a colon, `:`.  And
    no path in the list will start with drive letter, e.g., you won't see `E:`, you'll see `/e/...`.  This is fiction.
    If you get `PATH` from with Python (go ahead and test with IPython) you'll see what you see in Windows system
    environment variables dialog.  `PATH` is a list of directories separated by semicolons, `;`.  The slashes go the
    other way.  And any invidiual path that start from a specific volume begins with a drive letter, e.g., `E:`.

    Git Bash for Windows automatically translates between these two different representations of `PATH`.  On Windows,
    my `original_paths` looks like Windows paths.  Converting a Windows path from `str` form into a `PureWindowsPath`
    fixes the slashes, but if there's a drive letter, I have to handle that myself.

    In fact, depending on how you call this function, `path` could be a `Path`, a `PurePosixPath`, or a `PureWindowsPath`,
    and it could look a lot of different ways.  It could be a valid posix-style path already, e.g., '/home/wolf/bin'.
    It could be a valid windows-style path, e.g., r'C:\\Users\\Wolf\\bin'.  It might be some weird combination.  This
    function gets you part way to right thing, if you're on Windows and therefore the path is non-posix-compliant.  It
    fixes the drive part, dropping the `:` that is part of that.  Then `fix_path_separators` fixes everything else and
    returns a `PurePosixPath`.
    """
    if _is_windows or isinstance(path,PureWindowsPath):
        p = PureWindowsPath(path)
        if not p.drive:
            return fix_path_separators(p)
        drive = p.drive[0].lower()
        everything_else = str(p)[len(drive) + 1 :]
        return fix_path_separators(PurePosixPath(f"/{drive}/{everything_else}"))
    else:
        return PurePosixPath(path)
