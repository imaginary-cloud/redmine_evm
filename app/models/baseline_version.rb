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
    update_hours ? @end_date ||= end_date_when_updated_hours.to_date : @end_date ||= effective_date || baseline.due_date
  end

  private
  #se a versão está fechada maximum closed on se não continua o effective date

  #scope para closed_baseline_issues e para non_closed_baseline_issues
  def end_date_when_updated_hours # repensar nisto# compact com end_date e baseline_due_date
     is_closed ? baseline_issues.maximum('closed_on') : effective_date || baseline.due_date
  end
end