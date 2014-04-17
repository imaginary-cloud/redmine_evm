class EvmsController < ApplicationController
  unloadable

  include EvmsHelper

  respond_to :html, :json, :js

  def index
    @project = Project.find(params[:project_id])
    @baselines = @project.baselines.order( 'created_on DESC' ) #Order to get the current baseline first.
    respond_with(@baselines)
  end

  def chart_data
    project = Project.find(params[:project_id])
    baseline = Baseline.find(params[:id])

    data_to_chart = {}
    data_to_chart['pv'] = convert_to_chart(baseline.planned_value_by_week)
    data_to_chart['ac'] = convert_to_chart(project.actual_cost_by_week)
    data_to_chart['ev'] = convert_to_chart(project.earned_value_by_week)

    respond_to do |format|
      format.json { render :json => data_to_chart }
    end
  end

  def version_chart_data
    project = Project.find(params[:project_id])
    baseline = Baseline.find(params[:id])

    # baseline_versions = baseline.baseline_versions
    # baseline_versions.each do |bv|
    #   bv.planned_value_by_week
    #   version = Version.find(bv.original_version_id)
    #   version.actual_cost_by_week
    #   version.earned_value_by_week
    # end

    data_to_chart = {}
    data_to_chart['pv'] = convert_to_chart(baseline.planned_value_by_week)
    data_to_chart['ac'] = convert_to_chart(project.actual_cost_by_week)
    data_to_chart['ev'] = convert_to_chart(project.earned_value_by_week)

    respond_to do |format|
      format.json { render :json => data_to_chart }
    end
  end

end