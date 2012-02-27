require 'test/unit'
require 'yaml'

require 'helper'

class TestCoverPage < Test::Unit::TestCase
  def test_generate
    xml = Pubgen::CoverPage.generate("test.jpg")
    assert_match(/<image.*"test.jpg"\/>/, xml)
  end
end
