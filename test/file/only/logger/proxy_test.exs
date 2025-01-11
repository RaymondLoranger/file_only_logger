defmodule File.Only.Logger.ProxyTest do
  use ExUnit.Case, async: true

  alias File.Only.Logger.Proxy

  doctest Proxy

  describe "Proxy.lib/0" do
    test "returns the current library name" do
      assert Proxy.lib() == :file_only_logger
    end
  end
end
