# Test Directory Structure Requirements

Claude must always ensure that the `tests/` directory mirrors the
structure of the `src/` directory.\
Every Python module under `src/` must have a corresponding test module
under `tests/` following these rules:

## 1. Directory mirroring

If `src/` contains subpackages, `tests/` must replicate the exact folder
hierarchy.

Example:

    src/
      package_a/
        module_x.py
        module_y.py
      package_b/
        utils/
          transform.py

    tests/
      package_a/
        test_module_x.py
        test_module_y.py
      package_b/
        utils/
          test_transform.py

## 2. Test filename rules

For every file:

    src/<path>/<module>.py

Claude must create/test/update the corresponding file:

    tests/<path>/test_<module>.py

## 3. Required behaviors

Claude must:

-   Create the test file and directories if missing.
-   Update or rename test files when a source file is updated or
    renamed.
-   Remove test files if the corresponding source file is removed.
-   Keep imports inside test files consistent with the mirrored
    directory structure.

## 4. Constraints

-   Tests must **never** be stored inside `src/`.
-   When generating new modules in `src/`, Claude must automatically
    generate matching test scaffolds in `tests/`.
-   If there is any inconsistency, Claude must repair the test directory
    structure before continuing with the task.

## 5. `src/` is the source of truth

If `src/` and `tests/` disagree:

-   `src/` defines the canonical structure.
-   `tests/` must be aligned to it.
