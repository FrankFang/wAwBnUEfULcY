class Number < Struct.new(:value) 
  def inspect
    "<<#{self}>>"
  end
  def to_s
    "#{value}"
  end
end

class Add < Struct.new(:left, :right) 
  def inspect
    "<<#{self}>>"
  end
  def to_s
    "#{left} + #{right}"
  end
end

class Multiply < Struct.new(:left, :right) 
  def inspect
    "<<#{self}>>"
  end
  def to_s
    "#{left} * #{right}"
  end
end



class Number
  def reducible?
    false
  end
end
class Add
  def reducible?
    true
  end
end
class Multiply
  def reducible? 
    true
  end
end


class Add
  def reduce 
    if left.reducible?
      Add.new(left.reduce, right) # 用规约结果创建新 Add 
    elsif right.reducible?
      Add.new(left, right.reduce) # 用规约结果创建新 Add 
    else
      Number.new(left.value + right.value) # 求出结果
    end
  end
end

class Multiply
  def reduce 
    if left.reducible?
      Add.new(left.reduce, right) 
    elsif right.reducible?
      Add.new(left, right.reduce) 
    else
      Number.new(left.value * right.value) # 求出结果
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

ast = Add.new(
  Multiply.new(Number.new(1), Number.new(2)),
  Multiply.new(Number.new(3), Number.new(4)),
)
Machine.new(ast).run
# 注：puts 和 p 的区别是前者优先调用 to_s，后者优先调用 inspect
