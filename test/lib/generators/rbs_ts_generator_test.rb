require "test_helper"
require "generators/rbs_ts/rbs_ts_generator"

class RbsTsGeneratorTest < Rails::Generators::TestCase
  tests RbsTsGenerator
  destination Rails.root.join('tmp/generators')
  setup :prepare_destination

  # test "generator runs without errors" do
  #   assert_nothing_raised do
  #     run_generator ["arguments"]
  #   end
  # end
end
