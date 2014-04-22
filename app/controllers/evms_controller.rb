class EvmsController < ApplicationController
  unloadable

  include EvmsHelper

  def index
    @project = Project.find(params[:project_id])
    @baselines = @project.baselines.order( 'created_on DESC' ) #Order to get the current baseline first.
  end

  def chart_data
    project = Project.find(params[:project_id])
    baseline = Baseline.find(params[:id])

    # json format { 'pv':[[]], 'ac':[[]], 'ev':[[]] }
    data_to_chart = {}
    data_to_chart['pv'] = convert_to_chart(baseline.planned_value_by_week)
    data_to_chart['ac'] = convert_to_chart(project.actual_cost_by_week)
    data_to_chart['ev'] = convert_to_chart(project.earned_value_by_week)

    respond_to do |format|
      format.json { render :json => data_to_chart }
    end
  end

  def versions_chart_data
    project = Project.find(params[:project_id])
    baseline = Baseline.find(params[:id])

    baseline_versions = baseline.baseline_versions #Baseline Versions
    project_versions = project.versions            #Versions

    # json format { 'version1':{ 'pv':[[]], 'ac':[[]], 'ev':[[]] }, 'version2':{ 'pv':[[]], 'ac':[[]], 'ev':[[]] }, ... }
    versions_data_to_chart = {}
    project_versions.each do |version|
      baseline_version = baseline_versions.where(original_version_id = version.id).first
      data_to_chart = {}
      data_to_chart['name'] = version.name
      unless baseline_version.nil?
        data_to_chart['pv'] = convert_to_chart(baseline_version.planned_value_by_week)
      end
      data_to_chart['ac'] = convert_to_chart(version.actual_cost_by_week)
      data_to_chart['ev'] = convert_to_chart(version.earned_value_by_week)
      versions_data_to_chart[version.id] = data_to_chart
    end

    respond_to do |format|
      format.json { render :json => versions_data_to_chart }
    end
  end

  def evm_variables
    project = Project.find(params[:project_id])
    baseline = Baseline.find(params[:id])

    # json format { 'pv':value, 'ac':value, 'ev':value } 
    variables = {}
    variables['pv'] = baseline.planned_value
    variables['ac'] = project.actual_cost
    variables['ev'] = project.earned_value

    respond_to do |format|
      format.json { render :json => variables }
    end
  end

end