require 'opal/source_map'

class OpalSourceMapsController < ActionController::Base
  def show
    asset  = Rails.application.assets[params[:path]]
    source = asset.to_s
    map    = Opal::SourceMap.new(source, asset.pathname.to_s)

    render :text => map.to_s
  end
end
