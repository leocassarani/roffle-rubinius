RSpec::Matchers.define :be_a_refactoring_of do |expected|
  match do |actual|
    actual.to_sexp.should == expected.to_sexp
  end
end
