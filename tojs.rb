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
  def to_js
    "e => #{value}"
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
  def to_js
    "e => (#{left.to_js})(e) + (#{right.to_js})(e)"
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
  def to_js
    "e => (#{left.to_js})(e) * (#{right.to_js})(e)"
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
  def to_js
    "e => #{value}"
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
  def to_js
    "e => (#{left.to_js})(e) < (#{right.to_js})(e)"
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
  def to_js
    "e => e['#{name}']"
  end
end
class DoNothing
  def to_s
    'do-nothing'
  end
  def inspect
    "<<#{self}>>"
  end
  def ==(other_statement) # 你没有看错，Ruby 里的方法名可以是 ==
    other_statement.instance_of?(DoNothing)
  end
  def reducible?
    false
  end
end
class Assign < Struct.new(:name, :expression)
  def to_s
    "#{name} = #{expression}"
  end
  def inspect
    "<<#{self}>>"
  end
  def reducible?
    true
  end
  def to_js
    # "e => e['#{name}'] = (#{expression.to_js})(e)"
    "e => { return {...e, '#{name}': (#{expression.to_js})(e)} }"
  end
  def reduce(environment)
    if expression.reducible?
      new_expression = expression.reduce(environment)
      new_assign = Assign.new(name, new_expression)
      [new_assign, environment] # 此处的 [a, b] 表示返回 a 和 b 两个值
    else
      new_environment = environment.merge({ name => expression })
      [DoNothing.new, new_environment] # 此处的 [a, b] 表示返回 a 和 b 两个值
    end
  end
end
class If < Struct.new(:true_or_false, :if_true, :if_false)
  def to_s; "if (#{true_or_false}) { #{if_true} } else { #{if_false} }"; end
  def inspect; "<<#{self}>>"; end
  def reducible?; true; end 
  def reduce(environment)
    if true_or_false.reducible? 
      [If.new(true_or_false.reduce(environment), if_true, if_false), environment] 
    else
      case true_or_false
        when Boolean.new(true) 
          [if_true, environment] 
        when Boolean.new(false)
          [if_false, environment]
      end
    end
  end
  def to_js
    <<~EOS
      e => {
        if ( (#{true_or_false.to_js})(e) ){
          return (#{if_true.to_js})(e)
        }else{
          return (#{if_false.to_js})(e)
        }
      }
    EOS
  end
end
class Sequence < Struct.new(:first, :second)
  def to_s; "#{first}; #{second}" end
  def inspect; "<<#{self}>>" end
  def reducible?; true end
  def reduce(environment)
    case first 
      when DoNothing.new 
        [second, environment]
      else
        reduced_first, reduced_environment = first.reduce(environment)
        [Sequence.new(reduced_first, second), reduced_environment]
    end
  end
  def to_js
    <<~EOS
      e => {
        const newEnv = (#{first.to_js})(e)
        return (#{second.to_js})(newEnv)
      }
    EOS
  end
end
class While < Struct.new(:condition, :body) 
  def to_s; "while (#{condition}) { #{body} }" end 
  def inspect; "<<#{self}>>" end
  def reducible?; true end
  def reduce(environment)
    [If.new(condition, Sequence.new(body, self), DoNothing.new), environment]
  end
  def to_js
    <<~EOS
      e => {
        while( (#{condition.to_js})(e) ){
          e = (#{body.to_js})(e)
        }
        return e
      }
    EOS
  end
end
class Machine < Struct.new(:statement, :environment)
  def step
    self.statement, self.environment = statement.reduce(environment)
  end
  def run
    while statement.reducible?
      puts "#{statement}, #{environment}"
      step
    end
    puts "#{statement}, #{environment}"
  end
end

js_code_1 = Number.new(5).to_js
p js_code_1
# 在 JS 控制台中执行 eval(上面的输出结果含引号)({})
js_code_2 = Boolean.new(true).to_js
p js_code_2
# 在 JS 控制台中执行 eval(上面的输出结果含引号)({})
js_code_3 = Variable.new(:x).to_js
p js_code_3
# 在 JS 控制台中执行 eval(上面的输出结果含引号)({x:1})
js_code_4 = Add.new(Variable.new(:x), Number.new(1)).to_js
p js_code_4
# 在 JS 控制台中执行 eval(上面的输出结果含引号)({x:1})
js_code_5 = LessThan.new(
  Add.new(Variable.new(:x), Number.new(1)),
  Number.new(3)
).to_js
p js_code_5
# 在 JS 控制台中执行 eval(上面的输出结果含引号)({x:1})
js_code_6 = Assign.new(:y, Add.new(Variable.new(:x), Number.new(1))).to_js
p js_code_6
# 在 JS 控制台中执行 eval(上面的输出结果含引号)({x:1})
js_code_7 = If.new(
  LessThan.new(Variable.new(:x), Number.new(10)),
  Assign.new(:y, Number.new(1)),
  Assign.new(:y, Number.new(2))
).to_js
p js_code_7
# 在 JS 控制台中执行 eval(上面的输出结果含引号)({x:1})
js_code_8 = If.new(
  LessThan.new(Variable.new(:x), Number.new(10)),
  Sequence.new(
    Assign.new(:y, Number.new(1)),
    Assign.new(:z, Number.new(11)),
  ),
  Sequence.new(
    Assign.new(:y, Number.new(2)),
    Assign.new(:z, Number.new(22)),
  )
).to_js
p js_code_8
# 在 JS 控制台中执行 eval(上面的输出结果含引号)({x:1}

js_code_9 = While.new(
  LessThan.new(
    Variable.new(:x), Number.new(5)
  ),
  Assign.new(:x, Multiply.new(Variable.new(:x), Number.new(3))),
).to_js
p js_code_9
# 在 JS 控制台中执行 eval(上面的输出结果含引号)({x:1})