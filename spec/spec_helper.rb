RSpec::Matchers.define :be_equivalent_to do |expected|
  match do |actual|
    actual.to_sexp.should == expected.to_sexp
  end
end
