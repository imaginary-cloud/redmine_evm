class BaselineVersion < ActiveRecord::Base
  include Schedulable
  unloadable

  belongs_to :baseline 
  has_many :baseline_issues, dependent: :destroy
  belongs_to :version, :foreign_key => 'original_version_id'

  def start_date # start date for chart?
    @start_date ||= baseline_issues.minimum('start_date') || created_on.to_date #created_on of the normal original version. rename it in te database
  end

  def end_date # end date for chart? #com update_hours o caso muda # se não tiver closed issues como é? max due date? metodo privado para max de varias hipoteses?
    update_hours ? @end_date ||= max_end_date_when_updated_hours.to_date : @end_date ||= effective_date || baseline.due_date
  end

  private

  def max_end_date_when_updated_hours # repensar nisto
    baseline_issues.maximum('closed_on') || [effective_date, baseline.due_date].compact.max
  end
end

