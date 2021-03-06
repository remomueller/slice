# frozen_string_literal: true

# Groups together a set of designs on a specific date.
class Event < ApplicationRecord
  # Concerns
  include Blindable
  include Deletable
  include Forkable
  include Searchable
  include Sluggable
  include Squishable

  squish :name, :slug

  include Translatable
  translates :name

  attr_accessor :design_hashes

  # Callbacks
  after_save :set_event_designs, :reset_coverage

  # Scopes

  # Validations
  validates :name, :project_id, :user_id, presence: true
  validates :name, uniqueness: { scope: [:project_id, :deleted] }
  validates :slug, uniqueness: { scope: [:project_id, :deleted] }, allow_blank: true
  validates :slug, format: { with: /\A[a-z][a-z0-9\-]*\Z/ }, allow_blank: true

  # Relationships
  belongs_to :user
  belongs_to :project
  has_many :event_designs, -> { order(:position) }
  has_many :designs, -> { current }, through: :event_designs
  has_many :subject_events

  # Methods

  def param_and_name
    if slug.present?
      "#{name} (#{slug})"
    else
      "#{name} (##{id})"
    end
  end

  def unlink_sheets_in_background!(current_user, remote_ip)
    fork_process(:unlink_sheets!, current_user, remote_ip)
  end

  def unlink_sheets!(current_user, remote_ip)
    subject_events.find_each do |subject_event|
      subject_event.unlink_sheets!(current_user, remote_ip)
    end
    subject_events.destroy_all
  end

  def export_value(raw_data)
    raw_data ? id : name
  end

  private

  def reset_coverage
    subject_events.update_all(
      unblinded_responses_count: nil,
      unblinded_questions_count: nil,
      unblinded_percent: nil,
      blinded_responses_count: nil,
      blinded_questions_count: nil,
      blinded_percent: nil
    )
  end

  def set_event_designs
    return unless design_hashes && design_hashes.is_a?(Array)
    reset_event_designs
    create_event_designs
  end

  def reset_event_designs
    event_designs.destroy_all
  end

  def create_event_designs
    design_hashes.uniq! { |hash| hash[:design_id].to_i }
    design_hashes.each_with_index do |hash, index|
      design = project.designs.find_by(id: hash[:design_id])
      next unless design
      create_event_design(design, index, hash)
    end
  end

  def create_event_design(design, position, hash)
    event_designs.create(
      design_id: design.id, position: position,
      handoff_enabled: hash[:handoff_enabled],
      duplicates: hash[:duplicates].present? ? hash[:duplicates] : "highlight",
      requirement: hash[:requirement].present? ? hash[:requirement] : "always",
      conditional_event_id: hash[:conditional_event_id],
      conditional_design_id: hash[:conditional_design_id],
      conditional_variable_id: hash[:conditional_variable_id],
      conditional_operator: hash[:conditional_operator].present? ? hash[:conditional_operator] : "=",
      conditional_value: hash[:conditional_value]
    )
  end
end
