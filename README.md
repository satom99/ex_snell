# ex_snell

A JSON Predicate implementation
in accordance to the Snell
[RFC draft](https://tools.ietf.org/id/draft-snell-json-test-01.html).

### Usage

Let us consider the following predicate.

```elixir
predicate = %{
  op: "and",
  path: "/b",
  apply: [
    %{
      op: "less",
      value: 3
    },
    %{
      op: "more",
      value: 5
    },
    %{
      op: "type",
      value: "integer"
    }
  ]
}
```

In order to validate this against a structure,
a boolean function can be generated as follows.

```elixir
fun = Snell.parse(predicate)
```

Once we have this, we can proceed to verify whether a
struct suffices the given predicate.

```elixir
struct = %{
  b: 4
}
fun.(struct)
```

Do notice though that `type` values are Elixir types, and
thus not necessarily JavaScript types.

### Mineteria

This library was developed for use under the
[Mineteria framework](https://github.com/Mineteria-Development). \
However, it was decided to be released onto the public domain. Thanks! \
![Mineteria](https://i.imgur.com/PFB3NCw.png)
