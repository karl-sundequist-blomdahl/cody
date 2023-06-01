---
id: rule_config
title: Rule Config
---

Review rule configurations are nested under the `rules` key which is an array of
rule objects.

## Rule options

### `name`

| Type   | Required |
| ------ | -------- |
| String | Yes      |

The review rule's name. This is shown to users in the Pull Request and in the
Cody UI.

### `short_code`

| Type   | Required |
| ------ | -------- |
| String | Yes      |

The review rule's short code. This code is used to identify the rule in commands
and is shown in the Pull Request. It should contain only alphanumeric
characters, dashes, and underscores.

Short codes must be unique within a repository, because they are used to
identify separate rules in config. If more than one rule object specifies a
particular short code, the last rule object will overwrite all previous objects
with this short code.

### `active`

| Type    | Default |
| ------- | ------- |
| Boolean | True    |

Specify `active: false` in order to deactivate a rule. Deactivating a rule
prevents it from triggering on any future Pull Requests. Rules cannot be deleted
as they may have been used on previous Pull Requests.

> Note: Deleting a rule from your config YAML will also lead to the rule being
> deactivated. The difference is that by specifying `active: false` you can
> preserve the rule's configuration for future reference.

### `reviewer`

| Type   | Required |
| ------ | -------- |
| String | Yes      |

Either a GitHub username or the organization and slug of a GitHub Team. Teams
should be written as `organization/slug`.

If a GitHub user, that user will be assigned as a reviewer whenever the review
rule matches a Pull Request.

If a Team, a user will be randomly chosen from the Team's members and assigned
as a reviewer.

### `match`

| Type  | Required |
| ----- | -------- |
| Array | Yes      |

The `match` key specifies the match config for the review rule. This currently
has two possible keys:

* `path`: a list of regular expressions that are tested against the paths of
  files changed in the PR
* `diff`: a list of regular expressions that are tested against the combined
  diff of the PR
* `base_ref`: a list of regular expressions that are tested against the
  base ref of the PR

> Note: `path` and `diff` are currently mutually exclusive. It is an error to
> specify both in one match config.

If any of the supplied patterns matches the Pull Request, the rule is triggered.
