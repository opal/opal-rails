require 'opal/rails/spec_builder'
require 'fileutils'
require 'pathname'

class OpalSpecController < ActionController::Base  
  helper_method :clean_spec_path
  
  def run
    @assets = builder.clean_spec_files.map do |require_path|
      asset = get_asset require_path
      asset.to_a.map { |a| a.logical_path }      
    end.flatten.uniq
    @spec_files = builder.spec_files
    @using_pattern = pattern != nil
    @code = builder.main_code
  end

  private
  
  def get_asset(path)
    Rails.application.assets[path]
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
  
  delegate :clean_spec_path, to: :builder
end
