defmodule File.Only.Logger.Proxy.Try do
  @moduledoc """
  Removes or adds the console backend. Keeps trying in case of failures.
  """

  use PersistConfig

  alias File.Only.Logger.Log

  @flush true
  @times 7
  @wait 10

  @doc """
  Removes the console backend. If it fails, will retry up to #{@times} times.
  """
  @dialyzer {:no_match, remove_console_backend: 0}
  @spec remove_console_backend :: :ok | {:error, atom}
  def remove_console_backend do
    case Logger.remove_backend(:console, flush: @flush) do
      :ok ->
        :ok

      {:error, :not_found} ->
        :ok

      # Can never match per Dialyzer. But just in case...
      {:error, reason} ->
        :ok = Log.warn(:unremoved, {@wait, @times, reason, __ENV__})
        remove_console_backend(@times)
    end
  end

  @doc """
  Adds the console backend. If it fails, will retry up to #{@times} times.
  """
  @spec add_console_backend :: :ok | {:error, atom}
  def add_console_backend do
    case Logger.add_backend(:console, flush: @flush) do
      {:ok, _pid} ->
        :ok

      {:error, :already_present} ->
        :ok

      {:error, reason} ->
        :ok = Log.warn(:unadded, {@wait, @times, reason, __ENV__})
        add_console_backend(@times)
    end
  end

  ## Private functions

  @dialyzer {:no_unused, remove_console_backend: 1}
  @spec remove_console_backend(non_neg_integer) :: :ok | {:error, atom}
  defp remove_console_backend(0) do
    :ok = Log.warn(:remains_unremoved, {@wait, @times, __ENV__})
    {:error, :console_unremoved}
  end

  defp remove_console_backend(times_left) do
    Process.sleep(@wait)
    times_left = times_left - 1

    case Logger.remove_backend(:console, flush: @flush) do
      :ok ->
        :ok = Log.warn(:now_removed, {@wait, @times - times_left, __ENV__})

      {:error, reason} ->
        :ok = Log.warn(:still_unremoved, {@wait, times_left, reason, __ENV__})
        remove_console_backend(times_left)
    end
  end

  @spec add_console_backend(non_neg_integer) :: :ok | {:error, atom}
  defp add_console_backend(0) do
    :ok = Log.warn(:remains_unadded, {@wait, @times, __ENV__})
    {:error, :console_unadded}
  end

  defp add_console_backend(times_left) do
    Process.sleep(@wait)
    times_left = times_left - 1

    case Logger.add_backend(:console, flush: @flush) do
      {:ok, _pid} ->
        :ok = Log.warn(:now_added, {@wait, @times - times_left, __ENV__})

      {:error, reason} ->
        :ok = Log.warn(:still_unadded, {@wait, times_left, reason, __ENV__})
        add_console_backend(times_left)
    end
  end
end
