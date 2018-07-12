defmodule MastaniServer.Test.Statistics.PublishThrottleTest do
  use MastaniServer.TestTools

  alias MastaniServer.Accounts.User
  alias MastaniServer.{CMS, Statistics}
  alias Helper.ORM

  setup do
    guest_conn = simu_conn(:guest)
    user_conn = simu_conn(:user)
    {:ok, community} = db_insert(:community)

    {:ok, ~m(user_conn guest_conn community)a}
  end

  test "user first create content should add fresh throttle record.", ~m(community)a do
    {:ok, user} = db_insert(:user)
    post_attrs = mock_attrs(:post, %{community_id: community.id})
    {:ok, _post} = CMS.create_content(:post, %User{id: user.id}, post_attrs)

    {:ok, pt_record} = Statistics.PublishThrottle |> ORM.find_by(user_id: user.id)

    assert pt_record.date_count == 1
    assert pt_record.hour_count == 1
  end

  test "user create 2 content should update throttle record.", ~m(community)a do
    {:ok, user} = db_insert(:user)
    post_attrs = mock_attrs(:post, %{community_id: community.id})
    post_attrs2 = mock_attrs(:post, %{community_id: community.id})
    {:ok, _post} = CMS.create_content(:post, %User{id: user.id}, post_attrs)
    {:ok, _post} = CMS.create_content(:post, %User{id: user.id}, post_attrs2)

    {:ok, pt_record} = Statistics.PublishThrottle |> ORM.find_by(user_id: user.id)

    assert pt_record.date_count == 2
    assert pt_record.hour_count == 2
  end
end
