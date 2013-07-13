require "minitest/autorun"
require "minitest/pride"
require_relative "../semver"

module SemverRangeAssertions
  def assert_included_in(range, version)
    assert Semver.new(version).included_in?(range), "Expected #{range} to include #{version}"
  end

  def refute_included_in(range, version)
    refute Semver.new(version).included_in?(range), "Expected #{range} not to include #{version}"
  end
end

class TestSemver < Minitest::Test
  include SemverRangeAssertions

  def setup
    @version = Semver.new("1.2.3")
  end
  # Attributes

  def test_major
    assert_equal 1, @version.major
  end

  def test_minor
    assert_equal 2, @version.minor
  end

  def test_patch
    assert_equal 3, @version.patch
  end

  # <=>

  def test_spaceship_equal
    assert_equal 0, @version <=> Semver.new("1.2.3")
  end

  def test_spaceship_patch_gt
    assert_equal 1, @version <=> Semver.new("1.2.2")
  end

  def test_spaceship_patch_lt
    assert_equal -1, @version <=> Semver.new("1.2.4")
  end

  def test_spaceship_minor_gt
    assert_equal 1, @version <=> Semver.new("1.1.4")
  end

  def test_spaceshio_minor_lt
    assert_equal -1, @version <=> Semver.new("1.3.2")
  end

  def test_spaceship_major_gt
    assert_equal 1, @version <=> Semver.new("0.3.4")
  end

  def test_spaceship_major_lt
    assert_equal -1, @version <=> Semver.new("2.0.0")
  end

  # included_in?

  def test_included_in_canonical_equal
    assert_included_in "1.2.3", "1.2.3"
  end

  def test_included_in_canonical_unequal
    refute_included_in "1.2.0", "1.2.3"
  end

  def test_included_in_double_equal
    assert_included_in "== 1.2.3", "1.2.3"
  end

  def test_not_included_in_approximate_when_less_than
    refute_included_in "~> 1.2.3", "1.2.2"
  end

  def test_included_in_approximate_equal
    assert_included_in "~> 1.2.3", "1.2.3"
  end

  def test_included_in_approximate_when_greater_minor
    assert_included_in "~> 1.2.3", "1.3.0"
  end

  def test_not_included_in_approximate_when_greater_major
    refute_included_in "~> 1.2.3", "2.0.0"
  end

  COMPARATORS = {
    "lt" => "<",
    "lte" => "<=",
    "equal" => "=",
    "gte" => ">=",
    "gt" => ">",
  }

  REVERSE_COMPARATORS = {
    "lt" => ">=",
    "lte" => ">",
    "equal" => "!=",
    "gte" => "<",
    "gt" => "<=",
  }

  COMPARATORS.keys.each do |name|
    ["lt", "equal", "gt"].each do |test|
      define_method("test_included_in_#{name}_when_#{test}") do
        included_in(name, test)
      end
    end
  end

  def included_in(name, test)
    range = "#{COMPARATORS[name]} #{version_for(test)}"
    reverse_range = "#{REVERSE_COMPARATORS[name]} #{version_for(test)}"
    if name[0..1] == test[0..1] || name.end_with?("e") && test == "equal"
      assert_included_in(range, version_for(:equal))
    else
      refute_included_in(range, version_for(:equal))
    end
  end

  def version_for(test)
    {
      "gt" => @version.to_s,
      "equal" => @version.increment(:patch).to_s,
      "lt" => @version.increment(:patch).increment(:patch).to_s,
    }.fetch(test.to_s)
  end

  # increment

  def test_increment_major
    assert_equal "2.0.0", @version.increment(:major).to_s
  end

  def test_increment_minor
    assert_equal "1.3.0", @version.increment(:minor).to_s
  end

  def test_increment_patch
    assert_equal "1.2.4", @version.increment(:patch).to_s
  end
end
