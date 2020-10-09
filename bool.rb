class Number < Struct.new(:value)
  def inspect
    "<<#{self}>>"
  end
  def to_s
    "#{value}"
  end
  def reducible?
    false
  end
end

class Add < Struct.new(:left, :right)
  def inspect
    "<<#{self}>>"
  end
  def to_s
    "#{left} + #{right}"
  end
  def reducible?
    true
  end
  def reduce
    if left.reducible?
      Add.new(left.reduce, right) # 用规约结果创建新 Add 用于继续规约
    elsif right.reducible?
      Add.new(left, right.reduce) # 用规约结果创建新 Add 用于继续规约
    else
      Number.new(left.value + right.value) # 求出结果
    end
  end
end

class Multiply < Struct.new(:left, :right)
  def inspect
    "<<#{self}>>"
  end
  def to_s
    "#{left} * #{right}"
  end
  def reducible?
    true
  end
  def reduce
    if left.reducible?
      Multiply.new(left.reduce, right)
    elsif right.reducible?
      Multiply.new(left, right.reduce)
    else
      Number.new(left.value * right.value)
    end
  end
end

class Boolean < Struct.new(:value)
  def to_s
    value.to_s
  end
  def inspect
    "<<#{self}>>"
  end
  def reducible?
    false
  end
end

class LessThan < Struct.new(:left, :right)
  def to_s
    "#{left} < #{right}"
  end
  def inspect
    "<<#{self}>>"
  end
  def reducible?
    true
  end
  def reduce
    if left.reducible?
      LessThan.new(left.reduce, right)
    elsif right.reducible?
      LessThan.new(left, right.reduce)
    else
      Boolean.new(left.value < right.value)
    end
  end
end

class Machine < Struct.new(:expression)
  def step
    self.expression = expression.reduce
  end
  def run
    while expression.reducible? # 如果可规约
      puts expression # 就先打印出来
      step # 然后规约
    end
    puts expression # 此时 expression 必然不可规约，直接打印
  end
end

# 5 < 2+2
ast = LessThan.new( 
  Number.new(5), 
  Add.new(
    Number.new(2), 
    Number.new(2)
  )
)

Machine.new(ast).run

 



