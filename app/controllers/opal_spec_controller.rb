require 'opal/rails/spec_builder'
require 'fileutils'
require 'pathname'

class OpalSpecController < ActionController::Base  
  helper_method :clean_spec_path
  
  def run
    rails_assets = Rails.application.assets
    if rollup_assets?
      assets = ['opal'] + builder.clean_spec_files
      @rolled_up = assets.map do |spec_file|
        Rails.application.assets[spec_file].to_s
      end.join("\n").html_safe
    else
      @assets = builder.clean_spec_files.map do |require_path|
        asset = rails_assets[require_path]
        asset.to_a.map { |a| a.logical_path }      
      end.flatten.uniq      
    end
    @spec_files = builder.spec_files
    @pattern = pattern
    @main_code = builder.main_code
    respond_to do |format|
      format.html
      format.js
    end
  end

  private
  
  def rollup_assets?
    Rails.configuration.assets.debug == false
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
