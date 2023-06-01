---
id: rules
title: Review Rules
---

**Review Rules** control how Cody adds code reviewers to Pull Requests. Each
Rule has a selector and a reviewer.

## File Match

File Match rules test the paths of files changed in a PR against a regular
expression. If any paths match the regular expression, the corresponding
reviewer is added.

## Diff Match

Diff Match rules work like File Match rules but instead of testing the paths of
files, this rule tests the combined diff of each file.

## Base Match

Base Match rules test the base ref of the PR against a regular expression. If
there is a match, the corresponding reviewer is added.

## Always

Always rules are applied to every PR. Use these rules to specify a reviewer that
should always be added to incoming Pull Requests.
