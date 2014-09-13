module BaselinesHelper

  def label_bac
      @baseline.project_budget_at_completion.round(2)
  end

  def label_spi
      @baseline.schedule_performance_index.round(2)
  end

  def label_cpi
      @baseline.cost_performance_index.round(2)
  end

  def label_cost_performance
      @baseline.schedule_variance.round(2)
  end

  def label_schedule_performance
      @baseline.cost_variance.round(2)
  end 

end
