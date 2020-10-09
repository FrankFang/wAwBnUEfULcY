class Number < Struct.new(:value) 
  def inspect
    "<<#{self}>>"
  end
  def to_s
    "#{value}"
  end
end
# 上面代码表示每个 Number 对象拥有一个 :value 属性

class Add < Struct.new(:left, :right) 
  def inspect
    "<<#{self}>>"
  end
  def to_s
    "#{left} + #{right}"
  end
end
# 上面代码表示每个 Add 对象拥有 :left 和 :right 属性

class Multiply < Struct.new(:left, :right) 
  def inspect
    "<<#{self}>>"
  end
  def to_s
    "#{left} * #{right}"
  end
end
# 上面代码表示每个 Multiply 对象拥有 :left 和 :right 属性
ast = Add.new(
  Multiply.new(Number.new(1), Number.new(2)),
  Multiply.new(Number.new(3), Number.new(4)),
)

p ast

ast2 = Number.new(5)
p ast2

ast3 = Multiply.new(
  Number.new(1), 
  Multiply.new(
    Add.new(Number.new(2), Number.new(3)),
    Number.new(4)
))
p ast3