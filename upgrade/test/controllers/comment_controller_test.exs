defmodule Upgrade.CommentControllerTest do
  use Upgrade.ConnCase

  alias Upgrade.Comment
  @valid_attrs %{body: "some content"}
  @invalid_attrs %{}

  setup do
    conn = conn() |> put_req_header("accept", "application/json")
    {:ok, conn: conn}
  end

  test "lists all entries on index", %{conn: conn} do
    conn = get conn, comment_path(conn, :index)
    assert json_response(conn, 200)["data"] == []
  end

  test "shows chosen resource", %{conn: conn} do
    comment = Repo.insert! %Comment{}
    conn = get conn, comment_path(conn, :show, comment)
    assert json_response(conn, 200)["data"] == %{id: comment.id,
      body: comment.body,
      user_id: comment.user_id}
  end

  test "does not show resource and instead throw error when id is nonexistent", %{conn: conn} do
    assert_raise Ecto.NoResultsError, fn ->
      get conn, comment_path(conn, :show, -1)
    end
  end

  test "creates and renders resource when data is valid", %{conn: conn} do
    conn = post conn, comment_path(conn, :create), comment: @valid_attrs
    assert json_response(conn, 201)["data"]["id"]
    assert Repo.get_by(Comment, @valid_attrs)
  end

  test "does not create resource and renders errors when data is invalid", %{conn: conn} do
    conn = post conn, comment_path(conn, :create), comment: @invalid_attrs
    assert json_response(conn, 422)["errors"] != %{}
  end

  test "updates and renders chosen resource when data is valid", %{conn: conn} do
    comment = Repo.insert! %Comment{}
    conn = put conn, comment_path(conn, :update, comment), comment: @valid_attrs
    assert json_response(conn, 200)["data"]["id"]
    assert Repo.get_by(Comment, @valid_attrs)
  end

  test "does not update chosen resource and renders errors when data is invalid", %{conn: conn} do
    comment = Repo.insert! %Comment{}
    conn = put conn, comment_path(conn, :update, comment), comment: @invalid_attrs
    assert json_response(conn, 422)["errors"] != %{}
  end

  test "deletes chosen resource", %{conn: conn} do
    comment = Repo.insert! %Comment{}
    conn = delete conn, comment_path(conn, :delete, comment)
    assert response(conn, 204)
    refute Repo.get(Comment, comment.id)
  end
end
