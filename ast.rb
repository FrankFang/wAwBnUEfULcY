class Number < Struct.new(:value) 
end
# 上面代码表示每个 Number 对象拥有一个 :value 属性

class Add < Struct.new(:left, :right) 
end
# 上面代码表示每个 Add 对象拥有 :left 和 :right 属性

class Multiply < Struct.new(:left, :right) 
end
# 上面代码表示每个 Multiply 对象拥有 :left 和 :right 属性
ast = Add.new(
  Multiply.new(Number.new(1), Number.new(2)),
  Multiply.new(Number.new(3), Number.new(4)),
)

p ast