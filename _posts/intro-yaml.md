---
title: A minimal introduction to YAML format
date: 2019-02-01
---

# A minimal introduction to YAML format

YAML is used to describe key-value maps and arrays. You can recognize YAML file from `.yml` or `.yaml` file suffix.

A YAML dataset can be

1. Value

    ```yaml
    value
    ```

2. Array
    ```yaml
    - value 1
    - value 2
    - value 3
    ```
    or
    ```yaml
    [value 1, value 2, value 3]
    ```

3. Dictionary
    ```yaml
    key: value
    another_key: another value
    ```
    or
    ```yaml
    key:
      value
    another_key:
      another value
    ```

Now the real kicker is: value can be a YAML dataset!

```yaml
key:
  - value 1
  - another key:
      yet another key: value of yak
    another keys lost sibling:
      - more values
    this key has one value which is array too:
    - so indentation is not necessary here since keys often contain arrays
```

You can do multiline values:

```yaml
key: >
  Here's a value that is written over multiple lines
  but is actually still considered a single line until now.

  Placing double newline here will result in newline in the actual data.
```

Or if you want *verbatim* kind of style:
```yaml
key: |
  Now the each
  newline is
  treated as such so
```

YAML is also a superset of JSON (JavaScript Object Notation), so

```json
{
  "key": 
  [
    "value 1",
    {
      "another key": {"yet another key": "value of yak"},
      "another keys lost sibling": ["more values"],
      "this key has one value which is array too": ["so indentation is not necessary here since keys often contain arrays"]
    }
  ]
}
```

is also YAML.

For more information, see [yaml.org](https://yaml.org/) or [json.org](https://json.org).

