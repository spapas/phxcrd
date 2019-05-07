defmodule Phxcrd.Ldap do
  @connect_timeout 2_000

  def entry_to_map(entry) do
    %{
      object_name: entry.object_name |> List.to_string(),
      cn: Exldap.get_attribute!(entry, "cn"),
      mail: Exldap.get_attribute!(entry, "mail"),
      sn: Exldap.get_attribute!(entry, "sn"),
      uid: Exldap.get_attribute!(entry, "uid"),
      postOfficeBox: Exldap.get_attribute!(entry, "postOfficeBox"),
      departmentNumber: Exldap.get_attribute!(entry, "departmentNumber"),
      employeeNumber: Exldap.get_attribute!(entry, "employeeNumber"),
      givenName: Exldap.get_attribute!(entry, "givenName"),
      objectClass:
        with o when not is_nil(o) <- Exldap.get_attribute!(entry, "objectClass") do
          Enum.join(o, ",")
        end,
      initials:
        with o when not is_nil(o) <- Exldap.get_attribute!(entry, "initials") do
          Enum.join(o, ",")
        end
    }
  end

  def search_by_uid(con, uid) do
    case Exldap.search_field(con, "uid", uid) do
      {:ok, [entry | _]} -> {:ok, entry |> entry_to_map}
      {:ok, []} -> {:error, nil}
    end
  end

  def authenticate(username, password) do
    case Exldap.open(@connect_timeout) do
      {:ok, con} ->
        case Phxcrd.Ldap.search_by_uid(con, username) do
          {:ok, entry} ->
            case Exldap.verify_credentials(con, entry.object_name, password) do
              :ok ->
                {:ok, entry}

              {:error, _} ->
                {:error, "Invalid credentials"}
            end

          {:error, _} ->
            {:error, "Cannot find user "}
        end

      {:error, _} ->
        {:error, "Cannot authenticate"}
    end
  end
end
