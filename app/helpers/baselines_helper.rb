module BaselinesHelper

  def label_cost_performance_percentage
    if @baseline.schedule_variance < 0
      ((1 - @baseline.schedule_performance_index) * 100).round
    else
      ((@baseline.schedule_performance_index - 1) * 100).round
    end
  end

  def label_cost_performance_status
    if @baseline.schedule_variance < 0
      l(:label_behind_schedule)
    else
      l(:label_ahead_schedule)
    end
  end

  def label_schedule_performance_percentage
    if @baseline.cost_variance < 0
      ((1 - @baseline.cost_performance_index) * 100).round
    else
      ((@baseline.cost_performance_index - 1) * 100).round
    end
  end 

  def label_schedule_performance_status
    if @baseline.cost_variance < 0
      l(:label_above_budget)
    else
      l(:label_under_budget)
    end
  end 


end
