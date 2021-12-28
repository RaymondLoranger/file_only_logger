defmodule File.Only.Logger.Proxy.Try do
  @moduledoc """
  Removes or adds the console backend. Keeps trying in case of failures.
  """

  use PersistConfig

  alias File.Only.Logger.Log

  @after_compile get_env(:after_compile)
  @flush true
  @times 7
  @wait 10

  @doc """
  Removes the console backend. If it fails, will retry up to #{@times} times.
  """
  @spec remove_backend :: :ok | {:error, atom}
  def remove_backend do
    case Logger.remove_backend(:console, flush: @flush) do
      :ok ->
        :ok

      {:error, reason} ->
        :ok = Log.warn(:unremoved, {@wait, @times, reason, __ENV__})
        remove_backend(@times)
    end
  end

  @doc """
  Adds the console backend. If it fails, will retry up to #{@times} times.
  """
  @spec add_backend :: :ok | {:error, atom}
  def add_backend do
    case Logger.add_backend(:console, flush: @flush) do
      {:ok, _pid} ->
        :ok

      {:error, reason} ->
        :ok = Log.warn(:unadded, {@wait, @times, reason, __ENV__})
        add_backend(@times)
    end
  end

  ## Private functions

  @spec remove_backend(non_neg_integer) :: :ok | {:error, atom}
  defp remove_backend(0) do
    :ok = Log.warn(:remains_unremoved, {@wait, @times, __ENV__})
    {:error, :console_unremoved}
  end

  defp remove_backend(times_left) do
    Process.sleep(@wait)
    times_left = times_left - 1

    case Logger.remove_backend(:console, flush: @flush) do
      :ok ->
        :ok = Log.warn(:now_removed, {@wait, @times - times_left, __ENV__})

      {:error, reason} ->
        :ok = Log.warn(:still_unremoved, {@wait, times_left, reason, __ENV__})
        remove_backend(times_left)
    end
  end

  @spec add_backend(non_neg_integer) :: :ok | {:error, atom}
  defp add_backend(0) do
    :ok = Log.warn(:remains_unadded, {@wait, @times, __ENV__})
    {:error, :console_unadded}
  end

  defp add_backend(times_left) do
    Process.sleep(@wait)
    times_left = times_left - 1

    case Logger.add_backend(:console, flush: @flush) do
      {:ok, _pid} ->
        :ok = Log.warn(:now_added, {@wait, @times - times_left, __ENV__})

      {:error, reason} ->
        :ok = Log.warn(:still_unadded, {@wait, times_left, reason, __ENV__})
        add_backend(times_left)
    end
  end
end
