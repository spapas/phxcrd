defmodule Phxcrd.LdapTest do
  use ExUnit.Case

  test "Returns :error on error" do
    assert {:error, _} = Phxcrd.Ldap.authenticate("z", "z")
  end

  @tag :skip
  test "Returns :ok on ok" do
    assert {:ok, %{uid: "dtypxmd"}} = Phxcrd.Ldap.authenticate("dtypxmd", "")
  end
end
