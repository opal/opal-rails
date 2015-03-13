require 'opal/rails/spec_builder'

class OpalSpecController < ActionController::Base
  helper_method :spec_files, :pattern, :clean_spec_path

  def run
  end

  def file
    render js: builder.to_s
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

  delegate :spec_files, :clean_spec_path, to: :builder
end
