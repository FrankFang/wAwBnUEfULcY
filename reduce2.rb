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