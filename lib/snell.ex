defmodule Snell do
  @opcodes [
    :contains,
    :defined,
    :ends,
    :in,
    :less,
    :matches,
    :more,
    :starts,
    :test,
    :type,
    :undefined,
    :and,
    :not,
    :or
  ]

  def parse(predicate) do
    block = \
    try do
      predicate
      |> stringify
      |> build
    rescue
      _error -> false
    end

    quote do
      fn struct ->
        struct = struct
        |> Snell.stringify

        unquote(block)
      end
    end
    |> Code.eval_quoted
    |> elem(0)
  end

  def build(predicate) do
    path = predicate
    |> Map.get("path", "")
    |> String.trim("/")
    |> String.split("/")

    children = predicate
    |> Map.get("apply")

    value = predicate
    |> Map.get("value")

    sensitive = predicate
    |> Map.get("ignore_case")
    && false

    block = predicate
    |> Map.get("op")
    |> String.to_existing_atom
    |> case do
      code when code in [:and, :not, :or] ->
        blocks = children
        |> Enum.map(
          fn child ->
            parent = predicate
            |> Map.get("path", "")

            child
            |> Map.update("path", parent, &
              "#{parent}/#{&1}"
            )
            |> build
          end
        )

        __MODULE__
        |> apply(code, [blocks])
      code ->
        __MODULE__
        |> apply(code, [])
    end

    quote do
      path = unquote(path)
      value = unquote(value)
      sensitive = unquote(sensitive)

      field = struct
      |> pop_in(path)
      |> elem(0)
      || :undefined

      unquote(block)
    end
  end

  # First order
  def contains do
    quote do
      field =~ value
    end
  end

  def defined do
    quote do
      field != :undefined
    end
  end

  def ends do
    quote do
      field
      |> String.trim_trailing(value)
      != field
    end
  end

  def unquote(:in)() do
    quote do
      field in value
    end
  end

  def less do
    quote do
      field < value
    end
  end

  def matches do
    quote do
      value
      |> Regex.run(field)
      != nil
    end
  end

  def more do
    quote do
      field > value
    end
  end

  def starts do
    quote do
      field
      |> String.trim_leading(value)
      != field
    end
  end

  def test do
    quote do
      field === value
    end
  end

  def type do
    quote do
      field
      |> IEx.Info.info
      |> Enum.into(%{})
      |> Map.get("Data type")
      |> String.downcase
      == value
    end
  end

  def undefined do
    quote do
      field == :undefined
    end
  end

  # Second order
  def unquote(:and)(blocks) do
    blocks
    |> Enum.reduce(&
      quote do
        unquote(&1) && unquote(&2)
      end
    )
  end

  def unquote(:not)(blocks) do
    blocks = blocks
    |> Enum.map(&
      quote do
        !unquote(&1)
      end
    )

    __MODULE__
    |> apply(:and, [blocks])
  end

  def unquote(:or)(blocks) do
    blocks
    |> Enum.reduce(&
      quote do
        unquote(&1) || unquote(&2)
      end
    )
  end

  # Helpers
  def stringify(value) when is_map(value) do
    value
    |> Map.new(
      fn {key, value} ->
        {stringify(key), stringify(value)}
      end
    )
  end
  def stringify(value) when is_list(value) do
    value
    |> Enum.map(&stringify/1)
  end
  def stringify(value) when is_atom(value) do
    Atom.to_string(value)
  end
  def stringify(value), do: value
end
