module Member::Operation
  class Create < Trailblazer::Operation

    class Present < Trailblazer::Operation
      step Model(Member, :new)
      step Contract::Build(constant: Member::Contract::Create)
    end
    
    step Subprocess(Present)
    step Contract::Validate(key: :member)
    step Contract::Persist()
    step :check_make_greeter

    def check_make_greeter(ctx, model:, **)
      greeter = Greeter.find_by_member_id(model.id)
      
      return true if (model.make_greeter && greeter) || (!model.make_greeter && !greeter)
      return greeter.delete unless model.make_greeter

      order = Greeter.all.count
      Greeter.create({
        member_id: model.id,
        order_permanent: order,
        order_temporary: order
      })
    end
  end
end