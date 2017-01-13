defmodule Scipse.UserView do
  use Scipse.Web, :view
  alias Scipse.User

  def first_name(%User{name: name}) do
    name
    |> String.split(" ")
    |> Enum.at(0)
  end
end
