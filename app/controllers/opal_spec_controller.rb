require 'opal/rails/spec_builder'
require 'fileutils'
require 'pathname'

class OpalSpecController < ActionController::Base
  helper_method :spec_files, :pattern, :clean_spec_path, :runner_name

  def run
    runner = builder.runner_pathname
    runner.dirname.mkpath
    runner.open('w') { |f| f << builder.main_code }
  end


  private

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
