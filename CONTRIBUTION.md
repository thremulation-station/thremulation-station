# Thremulation Station Contribution Guide

Thank you for your interest in contributing to Thremulation Station. We've crafted this document to make it simple and easy for you to contribute. We recommend that you read these contribution guidelines carefully so that you spend less time working on GitHub issues and PRs and can be more productive contributing to this repository.

These guidelines will also help you post meaningful issues that will be more easily understood, considered, and resolved. These guidelines are here to help you whether you are creating a bug report, a feature request, an update to documentation, or just need some help.

## Table of Contents

- [Effective issue creation in Thremulation Station](#effective-issue-creation-in-thremulation-station)
  - [Why we create issues before contributing codes](#why-we-create-issues-before-contributing-code)
  - [What a good issue looks like](#what-a-good-issue-looks-like)
  - ["My issue isn’t getting enough attention"](#my-issue-isnt-getting-enough-attention)
  - ["I want to help!"](#i-want-to-help)
- [How we use Git and GitHub](#how-we-use-git-and-github)
  - [Forking](#forking)
  - [Branching](#branching)
  - [Commit messages](#commit-messages)
  - [What goes into a Pull Request](#what-goes-into-a-pull-request)
- [Submitting a Pull Request](#submitting-a-pull-request)
  - [What to expect from a code review](#what-to-expect-from-a-code-review)

## Effective issue creation in Thremulation Station

### Why we create Issues before contributing code

We generally create Issues in GitHub before contributing code. This helps front-load the conversation before the code recommendation. There are many situations that will make sense in one or two environments, but don't work as well in general. By creating an issue first, it creates an opportunity to bounce our ideas off each other to see what's feasible and what makes the most sense for the project as a whole.

By contrast, starting with a Pull Request (PR) makes it more difficult to revisit the approach. Many PRs are treated as mostly done and shouldn't need much work to get merged. Nobody wants to receive PR feedback that says "start over" or "closing: won't merge." That's discouraging to everyone, and we can avoid those situations if we have the discussion together earlier in the development process. It might be a mental switch for you to start the discussion earlier, but it makes us all more productive and more effective.

### What a good Issue looks like

We have a few types of issue templates to [choose from](https://github.com/mocyber/thremulation-station/issues/new/choose). If you don't find a template that matches or simply want to ask a question, create a blank issue and add the appropriate labels.

* **Bug report**: Create a report to help us improve
* **Feature request**: Suggest an idea for this project
* **Help**: You're stuck somewhere and need help
* **Documentation**: Used by the project team to track documentation updates

These Issue templates can help you get started, but if you need to make a blank Issue, that's totally fine.

### "My issue isn't getting enough attention"

First of all, **sorry about that!** We want you to have a great time with Thremulation Station.

The project maintainers are a group of volunteers, so we're doing our best to manage this project (as well as others) and the other obligations that go along with life.

Of course, feel free to bump your issues if you think they've been neglected for a prolonged period.

### "I want to help!"

**Now we're talking**. If you have a bug fix that you would like to contribute, please **find or open an Issue about it before you start working on it.** Talk about what you would like to do. It may be that somebody is already working on it, or that there are particular Issues that you should know about before implementing the change.

We enjoy working with contributors to get their code accepted. There are many approaches to fixing a problem and it is important to find the best approach before writing too much code.

## How we use Git and GitHub

### Forking

We follow the [GitHub forking model](https://help.github.com/articles/fork-a-repo/) for collaborating on the project. This model assumes that you have a remote called `upstream` which points to the official Thremulation Station repo, which we'll refer to in later code snippets.

### Branching

The basic branching workflow we follow for Thremulation Station:

* All changes for the next release are made to the `main` branch
* All branches should be made from the `devel` branch
* For bug fixes and other changes targeting the pending release during feature freeze, we will make those contributions to `main`

### Commit messages

* Feel free to make as many commits as you want, while working on a branch.
* Please use your commit messages to include helpful information on your changes. Commit messages that look like `update` are unhelpful to reviewers. Try to be clear and concise with the changes in a commit. Here's a [good blog](https://chris.beams.io/posts/git-commit/) on general best practices for commit messages.

### What goes into a Pull Request

* Please include an explanation of your changes in your PR description.
* Links to relevant issues, external resources, or related PRs are very important and useful.
* Please try to explain *how* and *why* your PR works.
* See [Submitting a Pull Request](#submitting-a-pull-request) for more info.

## Submitting a Pull Request

Push your local changes to your forked copy of the repository and submit a Pull Request. In the Pull Request, describe what your changes do and mention the number of the issue where discussion has taken place, e.g., `Closes #123` or `Resolves #123`. Check out Github's documentation on [Issue Keywords](https://docs.github.com/en/free-pro-team@latest/github/managing-your-work-on-github/linking-a-pull-request-to-an-issue#linking-a-pull-request-to-an-issue-using-a-keyword).

Always submit your pull against `devel` unless you are making changes for the pending release during feature freeze (see [Branching](#branching) for our branching strategy).

Then sit back and wait. We will probably have a discussion in the pull request and may request changes before merging. We're not trying to get in the way, but want to work with you to get your contributions in Thremulation Station.

**Once a PR is merged, the branch will be deleted.**

### What to expect from a code review

After a pull is submitted, it needs to get to reviewed. If you have commit permissions on the Thremulation Station repo you will probably perform these steps while submitting your Pull Request. If not, a member of the project team will do them for you, though you can help by suggesting a reviewer for your changes if you've interacted with someone while working on the issue.

Most likely, we will want to have a conversation in the pull request. We want to encourage contributions, but we also want to keep in mind how changes may affect other users. Please understand that even if a change is working in your environment, it still may not be a good fit for all users of the project.
