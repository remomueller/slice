class ProjectsController < ApplicationController
  before_filter :authenticate_user!

  def report
    @project = current_user.all_viewable_projects.find_by_id(params[:id])

    respond_to do |format|
      if @project
        format.html # report.html.erb
        format.json { render json: @project }
        format.js { render 'report' }
      else
        format.html { redirect_to projects_path }
        format.json { head :no_content }
        format.js { render nothing: true }
      end
    end
  end

  # def report
  #   @project = current_user.all_viewable_projects.find_by_id(params[:id])

  #   respond_to do |format|
  #     if @project
  #       format.html # report.html.erb
  #       format.json { render json: @project }
  #     else
  #       format.html { redirect_to projects_path }
  #       format.json { head :no_content }
  #     end
  #   end
  # end

  def remove_file
    @project = current_user.all_projects.find_by_id(params[:id])
    if @project
      @project.remove_logo!
    else
      render nothing: true
    end
  end

  # GET /projects
  # GET /projects.json
  def index
    current_user.pagination_set!('projects', params[:projects_per_page].to_i) if params[:projects_per_page].to_i > 0
    project_scope = current_user.all_viewable_projects

    @search_terms = params[:search].to_s.gsub(/[^0-9a-zA-Z]/, ' ').split(' ')
    @search_terms.each{|search_term| project_scope = project_scope.search(search_term) }

    @order = scrub_order(Project, params[:order], 'projects.name')
    project_scope = project_scope.order(@order)

    @project_count = project_scope.count
    @projects = project_scope.page(params[:page]).per( current_user.pagination_count('projects') )

    respond_to do |format|
      format.html # index.html.erb
      format.js
      format.json { render json: @projects }
    end
  end

  # GET /projects/1
  # GET /projects/1.json
  def show
    @project = current_user.all_viewable_projects.find_by_id(params[:id])

    respond_to do |format|
      if @project
        format.html # show.html.erb
        format.json { render json: @project }
      else
        format.html { redirect_to projects_path }
        format.json { head :no_content }
      end
    end
  end

  # GET /projects/new
  # GET /projects/new.json
  def new
    @project = current_user.projects.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @project }
    end
  end

  # GET /projects/1/edit
  def edit
    @project = current_user.all_projects.find_by_id(params[:id])
    redirect_to projects_path unless @project
  end

  # POST /projects
  # POST /projects.json
  def create
    @project = current_user.projects.new(post_params)

    respond_to do |format|
      if @project.save
        format.html { redirect_to @project, notice: 'Project was successfully created.' }
        format.json { render json: @project, status: :created, location: @project }
      else
        format.html { render action: "new" }
        format.json { render json: @project.errors, status: :unprocessable_entity }
      end
    end
  end

  # PUT /projects/1
  # PUT /projects/1.json
  def update
    @project = current_user.all_projects.find_by_id(params[:id])

    respond_to do |format|
      if @project
        if @project.update_attributes(post_params)
          format.html { redirect_to @project, notice: 'Project was successfully updated.' }
          format.json { head :no_content }
        else
          format.html { render action: "edit" }
          format.json { render json: @project.errors, status: :unprocessable_entity }
        end
      else
        format.html { redirect_to projects_path }
        format.json { head :no_content }
      end
    end
  end

  # DELETE /projects/1
  # DELETE /projects/1.json
  def destroy
    @project = current_user.all_projects.find_by_id(params[:id])
    @project.destroy if @project

    respond_to do |format|
      format.html { redirect_to projects_path }
      format.js { render 'destroy' }
      format.json { head :no_content }
    end
  end

  private

  def post_params
    params[:project] ||= {}

    params[:project].slice(
      :name, :description, :emails, :acrostic_enabled,
      # Uploaded Logo
      :logo, :logo_uploaded_at, :logo_cache
    )
  end
end
