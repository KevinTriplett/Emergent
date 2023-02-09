require 'test_helper'

class SpiderTest < MiniTest::Spec
  DatabaseCleaner.clean

  it "sets spider message and getting erases it" do
    DatabaseCleaner.cleaning do
      spider = Spider.create(name: "test_spider")

      spider.reload
      assert_nil spider.message
      Spider.set_message("test_spider", "hello this is a message")
      spider.reload
      assert_equal "hello this is a message", spider.message

      assert_equal "hello this is a message", Spider.get_message("test_spider")
      spider.reload
      assert_nil spider.message
      assert_nil Spider.get_message("test_spider")
    end
  end

  it "sets spider result and getting erases it" do
    DatabaseCleaner.cleaning do
      spider = Spider.create(name: "test_spider")

      spider.reload
      assert_nil spider.result
      Spider.set_result("test_spider", "test is the result")
      spider.reload
      assert_equal "test is the result", spider.result

      assert_equal "test is the result", Spider.get_result("test_spider")
      spider.reload
      assert_nil spider.result
    end
  end

end