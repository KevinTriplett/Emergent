require 'test_helper'

class SpiderTest < MiniTest::Spec
  DatabaseCleaner.clean

  it "creates spider if not created" do
    DatabaseCleaner.cleaning do
      spider = Spider.find_by_name("test_spider")
      assert_nil spider
      spider = Spider.get_spider("test_spider")
      assert spider
      assert spider.reload
    end
  end

  it "sets spider message and getting does not erase it but clearing it does" do
    DatabaseCleaner.cleaning do
      spider = Spider.get_spider("test_spider")

      spider.reload
      assert_nil spider.message
      Spider.set_message("test_spider", "hello this is a message")
      spider.reload
      assert Spider.message?("test_spider")
      assert_equal "hello this is a message", spider.message
      
      assert_equal "hello this is a message", Spider.get_message("test_spider")
      spider.reload
      assert spider.message
      assert Spider.message?("test_spider")
      assert Spider.get_message("test_spider")

      Spider.clear_message("test_spider")
      spider.reload
      assert_nil spider.message
      assert !Spider.message?("test_spider")
      assert_nil Spider.get_message("test_spider")
    end
  end

  it "appends spider message to message array" do
    DatabaseCleaner.cleaning do
      spider = Spider.get_spider("test_spider")
      Spider.set_message("test_spider", "hello this is the first message")
      spider.reload
      assert Spider.message?("test_spider")
      assert_equal "hello this is the first message", spider.message

      Spider.append_message("test_spider", "hello this is the second message")
      spider.reload
      assert_equal "hello this is the first message,hello this is the second message", spider.message
    end
  end

  it "sets spider result and getting does not erase it but clearing it does" do
    DatabaseCleaner.cleaning do
      spider = Spider.get_spider("test_spider")

      spider.reload
      assert_nil spider.result
      Spider.set_result("test_spider", "test is the result")
      spider.reload
      assert_equal "test is the result", spider.result

      assert Spider.result?("test_spider")
      assert_equal "test is the result", Spider.get_result("test_spider")
      spider.reload
      assert Spider.result?("test_spider")

      Spider.clear_result("test_spider")
      spider.reload
      assert !Spider.result?("test_spider")
      assert_nil spider.result
    end
  end

  it "sets and reports spider success and failure" do
    DatabaseCleaner.cleaning do
      spider = Spider.get_spider("test_spider")
      assert !Spider.result?("test_spider")
      assert !Spider.success?("test_spider")
      assert !Spider.failure?("test_spider")
      
      Spider.clear_result("test_spider")
      Spider.set_success("test_spider")
      assert Spider.result?("test_spider")
      assert Spider.success?("test_spider")
      assert !Spider.failure?("test_spider")
      
      Spider.clear_result("test_spider")
      Spider.set_failure("test_spider")
      assert Spider.result?("test_spider")
      assert !Spider.success?("test_spider")
      assert Spider.failure?("test_spider")
      
      Spider.clear_result("test_spider")
      assert !Spider.result?("test_spider")
    end
  end
end