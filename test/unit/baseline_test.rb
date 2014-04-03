require File.expand_path('../../test_helper', __FILE__)

class BaselineTest < ActiveSupport::TestCase


  def test_create
    b = Baseline.new(:project => Project.find(1), :name => 'baseline 10',
                    :due_date => '2011-03-25')
    assert b.save
    assert_equal 'Current', b.state
    assert_not_nil b.project_id
  end

  def test_invalid_due_date_validation
    b = Baseline.new(:project => Project.find(1), :name => 'baseline 10',
                    :due_date => '99999-01-01')
    assert !b.valid?
    b.effective_date = '2012-11-33'
    assert !b.valid?
    b.effective_date = '2012-31-11'
    assert !b.valid?
    b.effective_date = '-2012-31-11'
    assert !b.valid?
    b.effective_date = 'ABC'
    assert !b.valid?
    assert_include I18n.translate('activerecord.errors.messages.not_a_date'),
                   b.errors[:due_date]
  end

  def test_invalid_if_due_date_before_created_date
    b = Baseline.new(:project => Project.find(1), :name => 'baseline 10',
                     :due_date => Date.yesterday)
    assert_nil b
  end

end
