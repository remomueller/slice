# frozen_string_literal: true

# Allows project editors to modify projects.
class Editor::ProjectsController < ApplicationController
  before_action :authenticate_user!
  before_action :find_editable_project_or_redirect

  # GET /editor/projects/1/settings
  def settings
  end

  # GET /editor/projects/1/advanced
  def advanced
  end

  # GET /editor/projects/1/invite
  def invite
  end

  # POST /add-invite-row.js
  def add_invite_row
  end

  # POST /send-invites.js
  def send_invites
    params[:invites].select { |hash| hash[:email].to_s.strip.present? }.each do |hash|
      create_member_invite_from_hash(hash)
    end
    redirect_to settings_editor_project_path(@project)
  end

  # POST /editor/projects/1/invite_user.js
  def invite_user
    create_member_invite
    render 'projects/members'
  end

  # GET /editor/projects/1/edit
  def edit
  end

  # PATCH /editor/projects/1
  def update
    if @project.update(project_params)
      redirect_to settings_editor_project_path(@project), notice: 'Project was successfully updated.'
    else
      render :edit
    end
  end

  private

  # Overwriting application_controller
  def find_editable_project_or_redirect
    super(:id)
  end

  def redirect_without_project
    super(projects_path)
  end

  def project_params
    params.require(:project).permit(
      :name, :slug, :description, :disable_all_emails,
      :collect_email_on_surveys, :hide_values_on_pdfs,
      :randomizations_enabled, :adverse_events_enabled, :blinding_enabled,
      :handoffs_enabled, :auto_lock_sheets,
      # Uploaded Logo
      :logo, :logo_uploaded_at, :logo_cache, :remove_logo,
      # Will automatically generate a site if the project has no site
      :site_name
    )
  end

  def create_member_invite
    email = params[:invite_email].to_s.strip
    site_id = params[:site_id]
    editor = editor_generic(params[:editor])
    unblinded = unblinded_generic(params[:unblinded])
    add_or_invite_member(email, editor, unblinded, site_id)
  end

  def create_member_invite_from_hash(hash)
    email = hash[:email].to_s.strip
    site_id = hash[:site_id]
    editor = editor_generic(hash[:editor])
    unblinded = unblinded_generic(hash[:unblinded])
    add_or_invite_member(email, editor, unblinded, site_id)
  end

  def add_or_invite_member(email, editor, unblinded, site_id)
    invitee = associated_user_generic(email)
    if invitee
      add_existing_member_generic(invitee, editor, unblinded, site_id)
    elsif email.present?
      invite_new_member_generic(email, editor, unblinded, site_id)
    end
  end

  def editor_generic(editor)
    (editor == '1')
  end

  def unblinded_generic(unblinded)
    if @project.unblinded?(current_user)
      (unblinded == '1')
    else
      false
    end
  end

  def associated_user_generic(email)
    current_user.associated_users.find_by_email(email.split('[').last.to_s.split(']').first)
  end

  def member_scope_generic(site_id)
    site = @project.sites.find_by_id(site_id)
    if site
      site.site_users.where(project_id: @project)
    else
      @project.project_users
    end
  end

  def add_existing_member_generic(invitee, editor, unblinded, site_id)
    @member = member_scope_generic(site_id).where(user_id: invitee.id).first_or_create(creator_id: current_user.id)
    @member.update editor: editor, unblinded: unblinded
    @member.send_user_added_email_in_background!
  end

  def invite_new_member_generic(email, editor, unblinded, site_id)
    @member = member_scope_generic(site_id).where(invite_email: email).first_or_create(creator_id: current_user.id)
    @member.update editor: editor, unblinded: unblinded
    @member.send_user_invited_email_in_background!
  end
end
