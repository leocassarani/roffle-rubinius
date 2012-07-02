require 'pp'
require 'ruby2ruby'

require File.expand_path('../../spec_helper', __FILE__)
$LOAD_PATH.unshift(File.expand_path("../../../lib", __FILE__))
require 'roffle/refactorings/extract_method'

describe 'extracting a method' do
  it 'extracts without any local variables or args' do
    code = <<-RUBY
      def foo
        puts "123"
      end
    RUBY
    extracted_code = <<-RUBY
      def bar
        puts "123"
      end

      def foo
        bar
      end
    RUBY
    Roffle::Refactorings::ExtractMethod.extract_method(code, 'bar', 2, 2).should be_equivalent_to(extracted_code)
  end

  it 'ignores lines outside of the refactoring' do
    code = <<-RUBY
      def foo
        puts "123"
        puts "345"
      end
    RUBY
    extracted_code = <<-RUBY
      def bar
        puts "123"
      end

      def foo
        bar
        puts "345"
      end
    RUBY
    Roffle::Refactorings::ExtractMethod.extract_method(code, 'bar', 2, 2).should be_equivalent_to(extracted_code)
  end

  it "extracts multiple lines" do
    code = <<-RUBY
      def foo
        puts "123"
        puts "345"
        puts "567"
      end
    RUBY

    extracted_code = <<-RUBY
      def bar
        puts "345"
        puts "567"
      end

      def foo
        puts "123"
        bar
      end
    RUBY

    Roffle::Refactorings::ExtractMethod.extract_method(code, 'bar', 3, 4).should be_equivalent_to(extracted_code)
  end
end

