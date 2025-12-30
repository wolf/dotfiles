"""Tests for make-clone.py script."""
import importlib.util
import os
import subprocess
from pathlib import Path

import pytest

from conftest import run_script_with_coverage

SCRIPT_PATH = Path(__file__).parent.parent / "make-clone.py"

# Import the function we want to unit test using importlib (needed for files with hyphens)
spec = importlib.util.spec_from_file_location("make_clone", SCRIPT_PATH)
make_clone = importlib.util.module_from_spec(spec)
spec.loader.exec_module(make_clone)
derive_directory_from_url = make_clone.derive_directory_from_url


class TestDeriveDirectoryFromUrl:
    """Unit tests for URL parsing logic."""

    def test_ssh_url_with_git_suffix(self):
        assert derive_directory_from_url("git@github.com:user/repo.git") == "repo"

    def test_ssh_url_without_git_suffix(self):
        assert derive_directory_from_url("git@github.com:user/repo") == "repo"

    def test_https_url_with_git_suffix(self):
        assert derive_directory_from_url("https://github.com/user/repo.git") == "repo"

    def test_https_url_without_git_suffix(self):
        assert derive_directory_from_url("https://github.com/user/repo") == "repo"

    def test_ssh_nested_path(self):
        assert derive_directory_from_url("git@gitlab.com:group/subgroup/project.git") == "project"

    def test_file_url(self):
        assert derive_directory_from_url("file:///local/path/to/repo.git") == "repo"

    def test_git_protocol(self):
        assert derive_directory_from_url("git://github.com/user/repo.git") == "repo"


class TestMakeCloneIntegration:
    """Integration tests for make-clone.py script."""

    def test_clone_basic_ssh_url(self, git_repo, tmp_path):
        """Test cloning from a local repo using file:// URL."""
        clone_dir = tmp_path / "cloned-repo"

        result = run_script_with_coverage(
            SCRIPT_PATH,
            [f"file://{git_repo}", str(clone_dir)],
            cwd=tmp_path,
            capture_output=True,
            text=True,
        )

        assert result.returncode == 0
        assert clone_dir.exists()
        assert (clone_dir / ".git").exists()
        # Should print the absolute path
        assert str(clone_dir.resolve()) in result.stdout

    def test_clone_derives_directory_name(self, git_repo, tmp_path):
        """Test that directory is derived from URL when not provided."""
        # The repo name should be derived from the URL path
        # Clone in a subdirectory to avoid conflicts
        clone_parent = tmp_path / "clones"
        clone_parent.mkdir()
        expected_dir = clone_parent / "test-repo"

        result = run_script_with_coverage(
            SCRIPT_PATH,
            [f"file://{git_repo}"],
            cwd=clone_parent,
            capture_output=True,
            text=True,
        )

        assert result.returncode == 0
        assert expected_dir.exists()
        assert (expected_dir / ".git").exists()
        assert str(expected_dir.resolve()) in result.stdout

    def test_clone_with_git_options(self, git_repo_with_remote, tmp_path):
        """Test cloning with git options passed through."""
        git_repo, remote_repo = git_repo_with_remote

        # Create a branch in the local repo and push to remote
        subprocess.run(
            ["git", "checkout", "-b", "feature"],
            cwd=git_repo,
            check=True,
            capture_output=True,
        )
        subprocess.run(
            ["git", "commit", "--allow-empty", "-m", "Feature commit"],
            cwd=git_repo,
            check=True,
            capture_output=True,
        )
        subprocess.run(
            ["git", "push", "origin", "feature"],
            cwd=git_repo,
            check=True,
            capture_output=True,
        )

        clone_dir = tmp_path / "feature-clone"

        # Clone with --branch option
        result = run_script_with_coverage(
            SCRIPT_PATH,
            [f"file://{remote_repo}", str(clone_dir), "--branch", "feature"],
            cwd=tmp_path,
            capture_output=True,
            text=True,
        )

        assert result.returncode == 0
        assert clone_dir.exists()

        # Verify we're on the feature branch
        branch_result = subprocess.run(
            ["git", "branch", "--show-current"],
            cwd=clone_dir,
            capture_output=True,
            text=True,
            check=True,
        )
        assert branch_result.stdout.strip() == "feature"

    def test_clone_with_depth_option(self, git_repo_with_remote, tmp_path):
        """Test cloning with --depth option."""
        git_repo, remote_repo = git_repo_with_remote

        # Create multiple commits in local repo and push to remote
        for i in range(5):
            subprocess.run(
                ["git", "commit", "--allow-empty", "-m", f"Commit {i}"],
                cwd=git_repo,
                check=True,
                capture_output=True,
            )
        subprocess.run(
            ["git", "push", "origin", "main"],
            cwd=git_repo,
            check=True,
            capture_output=True,
        )

        clone_dir = tmp_path / "shallow-clone"

        # Clone with --depth 1
        result = run_script_with_coverage(
            SCRIPT_PATH,
            [f"file://{remote_repo}", str(clone_dir), "--depth", "1"],
            cwd=tmp_path,
            capture_output=True,
            text=True,
        )

        assert result.returncode == 0
        assert clone_dir.exists()

        # Verify shallow clone (should only have 1 commit accessible)
        log_result = subprocess.run(
            ["git", "rev-list", "--count", "HEAD"],
            cwd=clone_dir,
            capture_output=True,
            text=True,
            check=True,
        )
        assert log_result.stdout.strip() == "1"

    def test_clone_calls_initialize_repo(self, git_repo, tmp_path):
        """Test that cloning calls initialize_repo (which handles submodules/direnv)."""
        # This test verifies that initialize_repo is called after cloning.
        # Detailed submodule functionality is tested in git_shared tests.

        clone_dir = tmp_path / "test-clone"

        result = run_script_with_coverage(
            SCRIPT_PATH,
            [f"file://{git_repo}", str(clone_dir)],
            cwd=tmp_path,
            capture_output=True,
            text=True,
        )

        assert result.returncode == 0
        assert clone_dir.exists()
        assert (clone_dir / ".git").exists()
        # Verify initialize_repo was called by checking the path is printed
        assert str(clone_dir.resolve()) in result.stdout

    def test_clone_sets_up_direnv(self, git_repo, tmp_path, monkeypatch):
        """Test that cloning sets up direnv if .envrc.sample exists."""
        # Create .envrc.sample in the repo
        envrc_sample = git_repo / ".envrc.sample"
        envrc_sample.write_text("export TEST_VAR=value")
        subprocess.run(["git", "add", ".envrc.sample"], cwd=git_repo, check=True, capture_output=True)
        subprocess.run(
            ["git", "commit", "-m", "Add .envrc.sample"],
            cwd=git_repo,
            check=True,
            capture_output=True,
        )

        # Mock direnv being available
        mock_direnv_script = tmp_path / "mock-direnv"
        mock_direnv_script.write_text("#!/bin/bash\nexit 0")
        mock_direnv_script.chmod(0o755)

        # Add mock direnv to PATH
        monkeypatch.setenv("PATH", f"{tmp_path}:{os.getenv('PATH', '')}")

        clone_dir = tmp_path / "cloned-with-envrc"
        result = run_script_with_coverage(
            SCRIPT_PATH,
            [f"file://{git_repo}", str(clone_dir)],
            cwd=tmp_path,
            capture_output=True,
            text=True,
        )

        assert result.returncode == 0

        # Verify .envrc was created as symlink to .envrc.sample
        envrc = clone_dir / ".envrc"
        assert envrc.exists()
        assert envrc.is_symlink()
        assert envrc.resolve() == (clone_dir / ".envrc.sample").resolve()

    def test_clone_fails_with_invalid_url(self, tmp_path):
        """Test that cloning fails gracefully with invalid URL."""
        result = run_script_with_coverage(
            SCRIPT_PATH,
            ["https://invalid-domain-that-does-not-exist.com/repo.git", "test-dir"],
            cwd=tmp_path,
            capture_output=True,
            text=True,
        )

        assert result.returncode == 1
        assert "Error: git clone failed" in result.stderr

    def test_clone_help(self):
        """Test that --help works."""
        result = run_script_with_coverage(
            SCRIPT_PATH,
            ["--help"],
            capture_output=True,
            text=True,
        )

        assert result.returncode == 0
        assert "Clone a Git repository" in result.stdout
        assert "IMPORTANT: Repository URL must come first" in result.stdout
