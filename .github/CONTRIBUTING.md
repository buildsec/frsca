---
title: "How to Contribute"
description: "Contribute to to the Secure Software Factory."
date: 2021-11-25T18:10:00+00:00
updated: 2021-11-25T18:10:00+00:00
draft: false
weight: 410
sort_by: "weight"
template: "docs/page.html"
---

The SSF project welcomes any kind of contributions, from code to documentation
via fixing typos. Please feel free to raise an [issue] if you would like to
work on something major to ensure efficient collaboration and avoid duplicate
effort.

The code lives in the
[ssf repository](https://github.com/thesecuresoftwarefactory/ssf).

## Guidelines

* Use the provided templates to file an [issue] or a [pull request].
* Create a topic branch from where you want to base your work.
* Format the files properly. Please use the dedicated `Makefile` targets.
* If applicable, add some tests to validate your changes and ensure nothing
  else was accidentally broken.
* Commit messages must start with a capitalized and short summary
  (max. 50 chars) written in the imperative, followed by an optional, more
  detailed explanatory text which is separated from the summary by an empty
  line.
* Commit messages should follow best practices, including explaining the context
  of the problem and how it was solved, including in caveats or follow up
  changes required. They should tell the story of the change and provide readers
  understanding of what led to it. Please refer to
  [How to Write a Git Commit Message] for more details.
* If your [pull request] is a work in progress, create it as a
  [draft pull request].
* Any [pull request] inactive for 28 days will be automatically closed. If you
  need more time to work on it, ask maintainers, to add the appropriate label to
  it. Use the `@` mention in the comments.
* Unless explicitly asked, [pull request] which don't pass all the CI checks
  will not be reviewed. Use the `@` mention in the comments to ask maintainers
  to help you.

### Commit example

```COMMIT_EDITMSG
Enforce shell linting

Uses `shellcheck` and `shfmt` to lint and format shell scripts throughout the
project. Dedicated `Makefile` targets were created to automate the tasks and
the GitHub workflow was updated accordingly.

Fixes thesecuresoftwarefactory/ssf#64
```

The following commit is a good example as:

1. The fist line is a short description and starts with an imperative verb.
2. The first paragraph describes why this commit may be useful.
3. The last line points to an existing issue and will automatically close it.

[draft pull request]: https://github.blog/2019-02-14-introducing-draft-pull-requests/
[How to Write a Git Commit Message]: http://chris.beams.io/posts/git-commit
[issue]: https://github.com/thesecuresoftwarefactory/ssf/issues/new/choose
[pull request]: https://github.com/thesecuresoftwarefactory/ssf/pulls
