defmodule RenmoviesTest do
  use ExUnit.Case

  # test "test main call with parameters" do
  #   assert Renmovies.main(["--dry-r", "extract"]) == :wrong
  #   assert Renmovies.main(["--dry-run", "extract"]) == :dry_extract
  #   assert Renmovies.main(["--dry-run", "rename"]) == :dry_rename
  #   assert Renmovies.main(["--dry-run", "delete"]) == :dry_delete
  #   assert Renmovies.main(["extract"]) == :do_extract
  #   assert Renmovies.main(["rename"]) == :do_rename
  #   assert Renmovies.main(["delete"]) == :do_delete
  # end

  # test "test main call without any parameters" do
  #   assert Renmovies.main([]) == :show_print
  # end  

  test "only in dev" do
    Renmovies.main(["--dry-run", "extract"])
  end
end
