class SiteUsersController < ApplicationController
  before_action :authenticate_user!

  # # GET /site_users
  # # GET /site_users.json
  # def index
  #   site_user_scope = SiteUser.current
  #   @order = SiteUser.column_names.collect{|column_name| "site_users.#{column_name}"}.include?(params[:order].to_s.split(' ').first) ? params[:order] : "site_users.name"
  #   site_user_scope = site_user_scope.order(@order)
  #   @site_users = site_user_scope.page(params[:page]).per( 20 )

  #   respond_to do |format|
  #     format.html # index.html.erb
  #     format.js
  #     format.json { render json: @site_users }
  #   end
  # end

  # # GET /site_users/1
  # # GET /site_users/1.json
  # def show
  #   @site_user = SiteUser.current.find(params[:id])

  #   respond_to do |format|
  #     format.html # show.html.erb
  #     format.json { render json: @site_user }
  #   end
  # end

  # # GET /site_users/new
  # # GET /site_users/new.json
  # def new
  #   @site_user = SiteUser.new

  #   respond_to do |format|
  #     format.html # new.html.erb
  #     format.json { render json: @site_user }
  #   end
  # end

  # # GET /site_users/1/edit
  # def edit
  #   @site_user = SiteUser.current.find(params[:id])
  # end

  # POST /site_users/1.js
  def resend
    @site_user = SiteUser.current.find_by_id(params[:id])
    @site = current_user.all_sites.find_by_id(@site_user.site_id) if @site_user

    if @site and @site_user
      @site_user.send_invitation
      # resend.js.erb
    else
      render nothing: true
    end
  end


  # POST /site_users
  # POST /site_users.json
  def create
    @site = current_user.all_sites.find_by_id(params[:site_user][:site_id])
    @site_user = @site.site_users.find_or_create_by_project_id_and_invite_email(@site.project_id, params[:invite_email], { creator_id: current_user.id }) if @site

    respond_to do |format|
      if @site and @site_user
        format.html { redirect_to [@site_user.site.project, @site_user], notice: 'SiteUser was successfully created.' }
        format.json { render json: @site_user, status: :created, location: @site_user }
        format.js { render 'index' }
      else
        format.html { redirect_to root_path }
        format.json { head :no_content }
        format.js { render nothing: true }
      end
    end
  end

  def accept
    @site_user = SiteUser.find_by_invite_token(params[:invite_token])
    if @site_user and @site_user.user == current_user
      redirect_to [@site_user.site.project, @site_user.site], notice: "You have already been added to #{@site_user.site.name}."
    elsif @site_user and @site_user.user
      redirect_to root_path, alert: "This invite has already been claimed."
    elsif @site_user
      @site_user.update_attributes user_id: current_user.id
      redirect_to [@site_user.project, @site_user.site], notice: "You have been successfully been added to the site."
    else
      redirect_to root_path, alert: 'Invalid invitation token.'
    end
  end


  # # PUT /site_users/1
  # # PUT /site_users/1.json
  # def update
  #   @site_user = SiteUser.current.find(params[:id])

  #   respond_to do |format|
  #     if @site_user.update_attributes(post_params)
  #       format.html { redirect_to @site_user, notice: 'SiteUser was successfully updated.' }
  #       format.json { head :no_content }
  #     else
  #       format.html { render action: 'edit' }
  #       format.json { render json: @site_user.errors, status: :unprocessable_entity }
  #     end
  #   end
  # end

  # DELETE /site_users/1
  # DELETE /site_users/1.json
  def destroy
    @site_user = SiteUser.current.find_by_id(params[:id])
    @site = current_user.all_sites.find_by_id(@site_user.site_id) if @site_user

    respond_to do |format|
      if @site
        @site_user.destroy
        format.html { redirect_to [@site.project, @site] }
        format.json { head :no_content }
        format.js { render 'index' }
      elsif @site_user.user == current_user
        @site = @site_user.site
        @site_user.destroy
        format.html { redirect_to root_path }
        format.json { head :no_content }
        format.js { render 'index' }
      else
        format.html { redirect_to root_path }
        format.json { head :no_content }
        format.js { render nothing: true }
      end
    end
  end
end
