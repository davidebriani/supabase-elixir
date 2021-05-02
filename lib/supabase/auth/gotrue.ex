defmodule Supabase.Auth.GoTrue do
  alias Supabase.Connection

  @spec send_magic_link_email(Connection.t(), String.t()) :: any
  def send_magic_link_email(%Connection{} = conn, email) do
    case Connection.post(conn, "/auth/v1/magiclink", {:json, %{email: email}}) do
      %Finch.Response{status: 200} -> {:ok, "success"}
      %Finch.Response{body: body} -> {:error, body}
    end
  end

  @spec sign_up(Connection.t(), String.t(), String.t()) :: {:error, map()} | {:ok, map()}
  def sign_up(%Connection{} = conn, email, password) do
    case Connection.post(conn, "/auth/v1/signup", {:json, %{email: email, password: password}}) do
      %Finch.Response{body: body, status: 200} -> {:ok, body}
      %Finch.Response{body: body} -> {:error, body}
    end
  end

  @spec sign_in(Connection.t(), String.t()) :: {:ok, String.t()} | {:error, map()}
  def sign_in(%Connection{} = conn, email) do
    send_magic_link_email(conn, email)
  end

  @spec sign_in(Connection.t(), String.t(), String.t()) :: {:ok, String.t()} | {:error, map()}
  def sign_in(%Connection{} = conn, email, password) do
    case Connection.post(
           conn,
           "/auth/v1/token?grant_type=password",
           {:json, %{email: email, password: password}}
         ) do
      %Finch.Response{body: body, status: 200} -> {:ok, body}
      %Finch.Response{body: body} -> {:error, body}
    end
  end

  @spec refresh_access_token(Connection.t(), String.t()) :: {:ok, map()} | {:error, map()}
  def refresh_access_token(%Connection{} = conn, refresh_token) do
    case Connection.post(
           conn,
           "/auth/v1/token?grant_type=refresh_token",
           {:json, %{refresh_token: refresh_token}}
         ) do
      %Finch.Response{body: body, status: 200} -> {:ok, body}
      %Finch.Response{body: body} -> {:error, body}
    end
  end

  def user(%Connection{} = conn, access_token) do
    case Connection.get(
           conn,
           "/auth/v1/user",
           headers: [{"Authorization", "Bearer #{access_token}"}]
         ) do
      %Finch.Response{body: body, status: 200} -> {:ok, body}
      %Finch.Response{body: body} -> {:error, body}
    end
  end
end