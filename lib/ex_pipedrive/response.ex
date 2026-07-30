defmodule ExPipedrive.Response do
  @moduledoc """
  Maps Tesla results into `{:ok, value}` / `{:error, %ExPipedrive.Error{}}`.

  Resource modules should use this instead of matching raw Tesla envelopes so
  failure handling stays consistent.
  """

  alias ExPipedrive.Error

  @doc """
  On a successful HTTP status, invokes `fun` with the `Tesla.Env`.

  Treats Pipedrive `success: false` bodies as errors even when the status is in
  `success_statuses`. Transport failures and other statuses become
  `{:error, %ExPipedrive.Error{}}`.
  """
  @spec map({:ok, Tesla.Env.t()} | {:error, term()}, [pos_integer()], (Tesla.Env.t() -> term())) ::
          {:ok, term()} | {:error, Error.t()}
  def map({:ok, %Tesla.Env{status: status, body: body} = env}, success_statuses, fun)
      when is_list(success_statuses) and is_function(fun, 1) do
    cond do
      status in success_statuses and not api_failure?(body) ->
        {:ok, fun.(env)}

      true ->
        {:error, Error.from_env(env)}
    end
  end

  def map({:error, reason}, _success_statuses, fun) when is_function(fun, 1) do
    {:error, Error.from_transport(reason)}
  end

  defp api_failure?(%{"success" => false}), do: true
  defp api_failure?(%{success: false}), do: true
  defp api_failure?(_), do: false
end
