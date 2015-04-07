require "pry"

require "minitest/autorun"
require "minitest/reporters"
require "minitest/spec"

reporter = Minitest::Reporters::SpecReporter.new
Minitest::Reporters.use! reporter

