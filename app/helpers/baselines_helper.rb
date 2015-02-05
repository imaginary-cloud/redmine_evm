module BaselinesHelper

  def label_cost_performance_percentage
    if @baseline.schedule_variance < 0
      ((1 - @baseline.schedule_performance_index) * 100).round
    elsif @baseline.schedule_variance.round == 0
      nil
    else
      ((@baseline.schedule_performance_index - 1) * 100).round
    end
  end

  def label_cost_performance_status
    if @baseline.schedule_variance < 0
      l(:label_behind_schedule)
    elsif @baseline.schedule_variance.round == 0
      l(:label_on_schedule)
    else
      l(:label_ahead_schedule)
    end
  end

  def label_schedule_performance_percentage
    if @baseline.cost_variance < 0
      ((1 - @baseline.cost_performance_index) * 100).round
    elsif @baseline.cost_variance.round == 0
      nil
    else
      ((@baseline.cost_performance_index - 1) * 100).round
    end
  end 

  def label_schedule_performance_status
    if @baseline.cost_variance < 0
      l(:label_above_budget)
    elsif @baseline.cost_variance.round == 0
      l(:label_on_budget)
    else
      l(:label_under_budget)
    end
  end

end
