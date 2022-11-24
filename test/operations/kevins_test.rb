require "test_helper"

class KevinsTest < Minitest::Spec
  class Create < Trailblazer::Operation
    class Present < Trailblazer::Operation
      step :initialize_variable

      def initialize_variable(ctx, title:, **)
        # puts title.inspect
        ctx[:title] ||= "no title?"
      end
    end

    class MyTransaction
      def self.call((ctx, flow_options), *, &block)
        signal, (ctx, flow_options) = yield
        # puts "got signal #{signal} and ctx #{ctx.to_h}"
        # puts signal.to_h[:semantic].inspect
        true
      rescue
        # puts "Oh no an EEERRORR"
        [ Trailblazer::Operation::Railway.fail!, [ctx, flow_options] ]
      end
    end

    step Subprocess(Present)
    step :model,
      In() => [:title],
      Out() => [:name]
    step :show_name
    step Wrap( MyTransaction ) {
      step :update
      step :go_no_go
      step :are_we_still_here?
    }
    step :success
    fail :log_error

    def model(ctx, title:, **)
      # puts title.inspect
      # puts ctx[:params].inspect
      ctx[:name] = title
      true
    end

    def show_name(ctx, name:, **)
      # puts name.inspect
      # puts ctx[:params][:name].inspect
      true
    end

    def update(ctx, **)
      # puts "look at me in update"
      true
    end

    def go_no_go(ctx, **)
      # puts "oh no, let's abort"
      ctx[:error_msg] = "this is bullshit, I can't work like this"
      # raise "ERRORRR"
      true
    end

    def are_we_still_here?(ctx, **)
      # puts "yay! we made it!"
      true
    end

    def success(ctx, **)
      # puts "yay! it works"
      true
    end

    def log_error(ctx, error_msg:, **)
      # puts "ERR: #{error_msg}" || "Unkonwn error"
    end
  end

  # Run without debugging:
  # result = Create.(params: {title: "Suggestion for democracy"})
  result = Create.call(title: nil, params: {name: "Joe Kid"})


end
