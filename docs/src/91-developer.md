# [Developer documentation](@id dev_docs)

!!! note "Contributing guidelines"
    If you haven't, please read the [Contributing guidelines](90-contributing.md) first.

If you want to make contributions to this package, then this guide is for you.

## First time clone

!!! tip "If you have writing rights"
    If you have writing rights, you don't have to fork. Instead, simply clone and skip ahead. Whenever **upstream** is mentioned, use **origin** instead.

If this is the first time you work with this repository, follow the instructions below to clone the repository.

1. Fork this repository
2. Clone your fork (this will create a `git remote` called `origin`)
3. Add the original repository as a remote:

   ```bash
   git remote add upstream https://github.com/lucaferranti/DedekindCutArithmetic.jl
   ```

This will ensure that you have two remotes in your git: `origin` and `upstream`.
You will create branches and push to `origin`, and you will fetch and update your local `main` branch from `upstream`.

!!! warning "Warning"
    From now on, these instructions assume you are in the `DedekindCutArithmetic.jl` folder

## Linting and formatting

Install a plugin on your editor to use [EditorConfig](https://editorconfig.org).
This will ensure that your editor is configured with important formatting settings.

We use [https://pre-commit.com](https://pre-commit.com) to run the linters and formatters.
In particular, the Julia code is formatted using [JuliaFormatter.jl](https://github.com/domluna/JuliaFormatter.jl), so please install it globally first as follows (the following snippet is copy-pastable into the REPL)

```julia-repl
julia> import Pkg;
pkg> Pkg.activate();
pkg> Pkg.add("JuliaFormatter")
```

To install `pre-commit`, we recommend using [pipx](https://pipx.pypa.io) as follows:

```bash
# Install pipx following the link
pipx install pre-commit
```

With `pre-commit` installed, activate it as a pre-commit hook:

```bash
pre-commit install
```

To run the linting and formatting manually, enter the command below:

```bash
pre-commit run -a
```

**Now, you can only commit if all the pre-commit tests pass**.

## Testing

As with most Julia packages, you can just open Julia in the repository folder, activate the environment, and run `test`:

```julia-repl
julia> # press ]
pkg> activate .
pkg> test
```

Each test file is also stand-alone, hence to run a specific file you can `include` that from the REPL

```julia-repl
julia> include("test/test-cuts.jl")
```

## Working on a new issue

We try to keep a linear history in this repo, so it is important to keep your branches up-to-date.

1. Fetch from the remote and fast-forward your local main

   ```bash
   git fetch upstream
   git switch main
   git merge --ff-only upstream/main
   ```

2. Branch from `main` to address the issue (see below for naming)

   ```bash
   git switch -c 42-add-answer-universe
   ```

3. Push the new local branch to your personal remote repository

   ```bash
   git push -u origin 42-add-answer-universe
   ```

4. Create a pull request to merge your remote branch into the org main.

### Branch naming

- If there is an associated issue, add the issue number.
- If there is no associated issue, **and the changes are small**, add a prefix such as "typo", "hotfix", "small-refactor", according to the type of update.
- If the changes are not small and there is no associated issue, then create the issue first, so we can properly discuss the changes.
- Use dash separated imperative wording related to the issue (e.g., `14-add-tests`, `15-fix-model`, `16-remove-obsolete-files`).

### Commit message

- Use imperative or present tense, for instance: *Add feature* or *Fix bug*.
- Have informative titles.
- When necessary, add a body with details.
- If there are breaking changes, add the information to the commit message.

### Before creating a pull request

!!! tip "Atomic git commits"
    Try to create "atomic git commits" (recommended reading: [The Utopic Git History](https://blog.esciencecenter.nl/the-utopic-git-history-d44b81c09593)).

- Make sure the tests pass.
- Make sure the pre-commit tests pass.
- Fetch any `main` updates from upstream and rebase your branch, if necessary:

  ```bash
  git fetch upstream
  git rebase upstream/main BRANCH_NAME
  ```

- Then you can open a pull request and work with the reviewer to address any issues.

## Building and viewing the documentation locally

The first time you want to build the documentation locally, you will need to install all needed dependencies. To do so, run

```bash
julia docs/setup.jl
```

This needs to be done the fist time (i.e. if you don't have a `docs/Manifest.toml` file). The setup script needs to be rerun only if some external libraries used in the documentation example change.

Next, you can build the documentation locally by running

```bash
julia docs/liveserver.jl
```

This will open a preview of the documentation in your browser and watch the documentation source files, meaning the preview will automatically update on every documentation file change.

## Making a new release

To create a new release, you can follow these simple steps:

- Create a branch `release-x.y.z`
- Update `version` in `Project.toml`
- Update the `CHANGELOG.md`:
  - Rename the section "Unreleased" to "[x.y.z] - yyyy-mm-dd" (i.e., version under brackets, dash, and date in ISO format)
  - Add a new section on top of it named "Unreleased"
  - Add a new link in the bottom for version "x.y.z"
  - Change the "[unreleased]" link to use the latest version - end of line, `vx.y.z ... HEAD`.
- Create a commit "Release vx.y.z", push, create a PR, wait for it to pass, merge the PR.
- Go back to main screen and click on the latest commit (link: <https://github.com/lucaferranti/DedekindCutArithmetic.jl/commit/main>)
- At the bottom, write `@JuliaRegistrator register`

After that, you only need to wait and verify:

- Wait for the bot to comment (should take < 1m) with a link to a PR to the registry
- Follow the link and wait for a comment on the auto-merge
- The comment should said all is well and auto-merge should occur shortly
- After the merge happens, TagBot will trigger and create a new GitHub tag. Check on <https://github.com/lucaferranti/DedekindCutArithmetic.jl/releases>
- After the release is create, a "docs" GitHub action will start for the tag.
- After it passes, a deploy action will run.
- After that runs, the [stable docs](https://lucaferranti.github.io/DedekindCutArithmetic.jl/stable) should be updated. Check them and look for the version number.
