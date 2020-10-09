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
  def reduce(environment)
    if left.reducible?
      Add.new(left.reduce(environment), right) # 用规约结果创建新 Add 用于继续规约
    elsif right.reducible?
      Add.new(left, right.reduce(environment)) # 用规约结果创建新 Add 用于继续规约
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
  def reduce(environment)
    if left.reducible?
      Multiply.new(left.reduce(environment), right)
    elsif right.reducible?
      Multiply.new(left, right.reduce(environment))
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
  def reduce(environment)
    if left.reducible?
      LessThan.new(left.reduce(environment), right)
    elsif right.reducible?
      LessThan.new(left, right.reduce(environment))
    else
      Boolean.new(left.value < right.value)
    end
  end
end

class Variable < Struct.new(:name)
  # 为什么变量只有一个 :name 属性呢？
  def to_s
    name.to_s
  end
  def inspect
    "<<#{self}>>"
  end
  def reducible?
    true
  end
  def reduce(environment)
    environment[name]
    # 答案：因为变量的值放在环境里了
  end
end


class Machine < Struct.new(:expression, :environment)
  def step
    self.expression = expression.reduce(environment)
  end
  def run
    while expression.reducible? # 如果可规约
      puts expression # 就先打印出来
      step # 然后规约
    end
    puts expression # 此时 expression 必然不可规约，直接打印
  end
end

      # x + y
ast = Add.new(Variable.new(:x), Variable.new(:y))
p ast # << x + y >>
env = {x: Number.new(3), y: Number.new(4)} 

Machine.new(ast, env).run



