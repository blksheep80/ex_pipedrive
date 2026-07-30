defmodule ExPipedrive.Fields do
  @moduledoc """
  Resolves Pipedrive custom-field hashes and human-readable labels.

  Fetch definitions with `ExPipedrive.DealFields.list_page/2`,
  `ExPipedrive.PersonFields.list_page/2`, or
  `ExPipedrive.OrganizationFields.list_page/2`. API v2 calls the hash a
  `field_code`; it is the key used in an entity's `custom_fields` map.

  For example:

      {:ok, page} = ExPipedrive.DealFields.list_page(client)
      {:ok, "a31aaf5e2c4843027e1e183d7001686afb9781d0"} =
        ExPipedrive.Fields.key_for(page, "Customer tier")

      {:ok, "Customer tier"} =
        ExPipedrive.Fields.label_for(
          page,
          "a31aaf5e2c4843027e1e183d7001686afb9781d0"
        )

  `resolve/2` accepts a `%ExPipedrive.Page{}`, legacy
  `%ExPipedrive.PagedResult{}`, a list, or a map whose values are field
  definitions. It returns the matching definition for either its `field_code`
  (legacy `key`) or `field_name` (legacy `name`).
  """

  alias ExPipedrive.Field
  alias ExPipedrive.Page
  alias ExPipedrive.PagedResult

  @type field :: Field.t() | map()
  @type collection :: Page.t() | PagedResult.t() | [field()] | %{optional(term()) => field()}

  @doc """
  Finds a field definition by its field hash/code or human-readable label.

  Field codes take precedence over labels when the same string could identify
  both. Returns `:error` when no definition matches.
  """
  @spec resolve(collection(), String.t() | atom()) :: {:ok, field()} | :error
  def resolve(fields, value) when is_binary(value) or is_atom(value) do
    value = to_string(value)
    fields = field_list(fields)

    case Enum.find(fields, &(field_code(&1) == value)) do
      nil ->
        case Enum.find(fields, &(field_label(&1) == value)) do
          nil -> :error
          field -> {:ok, field}
        end

      field ->
        {:ok, field}
    end
  end

  @doc """
  Returns the custom-field hash (`field_code`) for a field label or code.
  """
  @spec key_for(collection(), String.t() | atom()) :: {:ok, String.t()} | :error
  def key_for(fields, value) do
    with {:ok, field} <- resolve(fields, value),
         key when is_binary(key) <- field_code(field) do
      {:ok, key}
    else
      _ -> :error
    end
  end

  @doc """
  Returns the human-readable field label for a field hash/code or label.
  """
  @spec label_for(collection(), String.t() | atom()) :: {:ok, String.t()} | :error
  def label_for(fields, value) do
    with {:ok, field} <- resolve(fields, value),
         label when is_binary(label) <- field_label(field) do
      {:ok, label}
    else
      _ -> :error
    end
  end

  defp field_list(%Page{data: fields}), do: fields
  defp field_list(%PagedResult{data: fields}), do: fields
  defp field_list(fields) when is_list(fields), do: fields

  defp field_list(fields) when is_map(fields) do
    if field_definition?(fields), do: [fields], else: Map.values(fields)
  end

  defp field_list(_), do: []

  defp field_definition?(field) do
    is_binary(field_code(field)) or is_binary(field_label(field))
  end

  defp field_code(%Field{field_code: field_code}) when is_binary(field_code), do: field_code
  defp field_code(%Field{key: key}) when is_binary(key), do: key

  defp field_code(%{} = field),
    do:
      Map.get(field, :field_code) ||
        Map.get(field, "field_code") ||
        Map.get(field, :key) ||
        Map.get(field, "key")

  defp field_code(_), do: nil

  defp field_label(%Field{field_name: field_name}) when is_binary(field_name), do: field_name
  defp field_label(%Field{name: name}) when is_binary(name), do: name

  defp field_label(%{} = field),
    do:
      Map.get(field, :field_name) ||
        Map.get(field, "field_name") ||
        Map.get(field, :name) ||
        Map.get(field, "name")

  defp field_label(_), do: nil
end
