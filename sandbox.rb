def fun(*args)

  case args
  when Array
    p args.first.class
    p args

  end

end


a = fun
p a.empty?
fun(1)
fun(1,2,3)
fun([1,2,3])
