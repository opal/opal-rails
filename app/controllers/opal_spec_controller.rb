require 'opal/rails/spec_builder'
require 'fileutils'
require 'pathname'

class OpalSpecController < ActionController::Base
  helper_method :spec_files, :pattern, :clean_spec_path, :runner_name
  helper_method :check_errors_for, :builder

  def run
  end


  private

  # This will deactivate the requirement to precompile assets in this controller
  # as specs shouldn't go to production anyway.
  def check_errors_for(*)
    #noop
  end

  def pattern
    params[:pattern]
  end

  def builder
    @builder ||= Opal::Rails::SpecBuilder.new(
      spec_location: Rails.application.config.opal.spec_location,
      sprockets: Rails.application.config.assets,
      pattern: pattern,
    )
  end

  def runner_name
    builder.runner_pathname.basename.to_s.gsub(/(\.js)?\.rb$/, '')
  end

  delegate :spec_files, :clean_spec_path, to: :builder
end
