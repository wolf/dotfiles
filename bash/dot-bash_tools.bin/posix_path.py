from os import PathLike
import platform
from pathlib import PurePosixPath, PureWindowsPath


_is_windows = platform.system() == "Windows"


def fix_path_separators(path: PathLike) -> PurePosixPath:
    return PurePosixPath(str(path).replace('\\+', '/').replace('/+', '/'))


def posix_path(path: PathLike) -> PurePosixPath:
    """
    Convert a platform-dependent string into a `pathlib.Path`

    Why is this hard?  Git Bash for Windows is a special case.  WSL acts exactly like any other Linux. It is not
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

    Could I have converted all of `original_paths` at once?  Yes.  I think it would be more complicated and probably use
    regular expressions.  `$PATH` doesn't have a ton of elements.  Simple is fast enough.
    """
    if _is_windows:
        p = PureWindowsPath(path)
        if not p.drive:
            return fix_path_separators(p)
        drive = p.drive[0].lower()
        everything_else = str(p)[len(drive) + 1 :]
        return fix_path_separators(PurePosixPath(f"/{drive}/{everything_else}"))
    else:
        return PurePosixPath(path)
