class Baseline < ActiveRecord::Base
  include Redmine::SafeAttributes
  include Schedulable
  include Forecastable
  unloadable

  belongs_to :project
  has_many :baseline_issues, dependent: :destroy
  has_many :baseline_versions, dependent: :destroy

  validates :name, :due_date, :presence => true


  before_create {update_baseline_status("#{l(:label_old_baseline)}", project_id)}
  after_destroy {update_baseline_status("#{l(:label_current_baseline)}", project_id)}

  acts_as_customizable

  safe_attributes 'name',
  'description',
  'due_date'

  def create_versions versions, versions_to_exclude, update_estimated_hours
    unless versions.nil?
      versions.each do |version|
        versions_to_exclude.nil? ? exclude = false : exclude =  versions_to_exclude.include?(version.id)
        if version.closed? && update_estimated_hours == "1"
        baseline_versions.create(original_version_id: version.id, effective_date: version.get_end_date(self.id), start_date: version.start_date || version.get_start_date(self.id), name: version.name, exclude: exclude)  
        else
        baseline_versions.create(original_version_id: version.id, effective_date: version.due_date, start_date: version.start_date || version.get_start_date(self.id), name: version.name, exclude: exclude)
        #baseline_versions.create(original_version_id: version.id, effective_date: version.get_end_date(self.id), start_date: version.get_start_date(self.id), name: version.name, exclude: exclude)
        end
      end
    end
  end

  def create_issues issues, update_estimated_hours
    unless issues.nil?
      issues.each do |issue|
        baseline_issue = BaselineIssue.new(original_issue_id: issue.id, done_ratio: issue.done_ratio, status: issue.status.name, due_date: issue.due_date, start_date: issue.start_date || issue.created_on, exclude: false)

        baseline_version = self.baseline_versions.find_by_original_version_id(issue.fixed_version_id)
        unless baseline_version.nil?
          baseline_issue.baseline_version_id = baseline_version.id
          baseline_issue.exclude = baseline_version.exclude
        end

        if update_estimated_hours == "1"
          puts issue.status.name
          if issue.status.name == "Closed"
            baseline_issue.estimated_hours = issue.spent_hours
            if issue.due_date.nil?
              issue.time_entries.empty? ? baseline_issue.due_date = issue.updated_on.to_date : baseline_issue.due_date = issue.time_entries.maximum('spent_on')
            end  
          else
            baseline_issue.estimated_hours = issue.estimated_hours || 0
            #issue.due_date.nil? ? baseline_issue.due_date = issue.time_entries.maximum('spent_on') : baseline_issue.due_date = issue.due_date
          end
        else
          baseline_issue.estimated_hours = issue.estimated_hours || 0
          if issue.status.name == "Closed"
            if issue.due_date.nil?
              issue.time_entries.empty? ? baseline_issue.due_date = issue.updated_on.to_date : baseline_issue.due_date = issue.time_entries.maximum('spent_on')
            end
          end
          # if issue.done_ratio == 100 || issue.status.name == "Rejected"
          #   issue.time_entries.empty? ? baseline_issue.due_date = issue.updated_on.to_date : baseline_issue.due_date = issue.time_entries.maximum('spent_on')
          # else
          #   issue.due_date.nil? ? baseline_issue.due_date = issue.time_entries.maximum('spent_on') : baseline_issue.due_date = issue.due_date
          # end
        end 

        baseline_issue.save
        baseline_issues << baseline_issue
        
      end
    end
  end

  def versions_to_exclude operator, selected_target_versions, project_id
    target_versions = []
    all_versions = Project.find(project_id).versions.map(&:id)
    unless selected_target_versions.nil?
      target_versions = selected_target_versions.collect{|v| v.to_i}
    end
    
    if operator == "is"
      all_versions - target_versions #All the other not selected versions are excluded.
    elsif operator == "is not"
      target_versions
    elsif operator == "any"
      target_versions
    elsif operator == "none"
      all_versions
    end
  end

  #Returns the excluded versions from this baseline
  def get_excluded_versions
    baseline_versions.where(exclude: true).map(&:original_version_id)
  end

  def get_targeted_versions
    baseline_versions.where(exclude: false).map(&:original_version_id)
  end

  def update_baseline_status status, project_id
    project = Project.find(project_id) 
    baseline = project.baselines.last 
    if baseline 
      baseline.state = status 
      baseline.save
    end
  end

  def end_date
    due_date
  end

  #Schedule Performance Index (SPI)
  def schedule_performance_index 
    if self.planned_value != 0
      project.earned_value(self).to_f / self.planned_value
    else
      return 0
    end
  end

  #Cost Performance Index (CPI)
  def cost_performance_index
    if project.actual_cost(self) != 0
      project.earned_value(self).to_f / project.actual_cost(self)
    else
      return 0
    end
  end

  #Schedule Variance (SV)
  def schedule_variance
    project.earned_value(self) - self.planned_value
  end

  #Cost Variance (CV)
  def cost_variance
    project.earned_value(self) - project.actual_cost(self)
  end

end
