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
p Number.new(1).reducible?

p Add.new(Number.new(1), Number.new(2)).reducible? 
