class OpalSpecController < ActionController::Base
  helper_method :spec_files

  def run
  end

  def file
    spec_file = Dir["#{spec_location}/#{params[:path]}*.{rb,opal}"].first
    Opal.paths.concat Rails.application.config.assets.paths
    builder = Opal::Builder.new
    file = File.new spec_file
    builder.build_str file.read, spec_file

    render js: builder.to_s
  end

  private

  def spec_files
    @spec_files ||= some_spec_files || all_spec_files
  end

  def specs_param
    params[:pattern]
  end

  def some_spec_files
    return if specs_param.blank?
    specs_param.split(':').map { |path| spec_files_for_glob(path) }.flatten
  end

  def all_spec_files
    spec_files_for_glob '**/*_spec{.js,}'
  end

  def spec_files_for_glob glob = '**'
    Dir[Rails.root.join("#{spec_location}/#{glob}.{rb,opal}")].map do |path|
      path.split("#{spec_location}/").flatten.last.gsub(/(\.rb|\.opal)/, '')
    end.uniq
  end

  def spec_location
    Rails.application.config.opal.spec_location
  end
end
