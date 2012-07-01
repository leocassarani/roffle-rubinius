class Array
  def comments
    []
  end

  def sexp_type
    first
  end

  def to_sexp
    Sexp.from_array(Rubinius::AST::Block.new(first.line, self).to_sexp)
  end
end

module Roffle
  module Serializer
    def self.to_ruby(ast)
      Ruby2Ruby.new.process(ast.to_sexp)
    end
  end

  class FindsBodies
    def self.find(method_definition, lines)
      body = method_definition.body.array
      body.select { |i| lines.include? i.line }
    end
  end

  class CreatesMethods
    def self.create_new_method(new_method_name, body)
      code = <<-RUBY
def #{new_method_name}
  #{Serializer.to_ruby(body)}
end
      RUBY
      Serializer.to_ruby(code)
    end
  end

  module Refactorings
    class ExtractMethod
      def self.extract_method(code, new_method_name, start_line, end_line)
        new(code, new_method_name, start_line..end_line).extract_method
      end

      def initialize(code, new_method_name, lines)
        @code = code
        @new_method_name = new_method_name
        @lines = lines
      end

      def extract_method
        ast = @code.to_ast

        body = FindsBodies.find(ast, @lines)

        extracted = CreatesMethods.create_new_method(@new_method_name, body)
        original = replace_body(ast, @lines, @new_method_name)

        "#{extracted}\n\n#{original}"
      end

      def replace_body(method_definition, lines, new_method_name)
        replacement = "#{new_method_name}()".to_ast
        new_body = substitute_lines(method_definition.body.array, lines, replacement)
        method_definition.body.array = new_body
        Serializer.to_ruby(method_definition)
      end

      def substitute_lines(body, lines, ast)
        new_body = []
        new_body.concat body.take_while { |i| i.line < lines.first }
        new_body << ast
        new_body.concat body.drop_while { |i| i.line <= lines.last }
        new_body
      end
    end
  end
end

