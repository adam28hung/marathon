require 'test_helper'

class ContestCellTest < Cell::TestCase
  test "show" do
    invoke :show
    assert_select 'p'
  end


end
