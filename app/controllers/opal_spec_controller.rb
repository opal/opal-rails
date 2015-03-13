class OpalSpecController < ActionController::Base
  helper_method :spec_files, :pattern, :clean_spec_path

  def run
  end

  def file
    sprockets   = Rails.application.config.assets
    path_finder = Opal::HikePathFinder.new(Opal.paths + sprockets.paths)

    builder = Opal::Builder.new(
      compiler_options: Opal::Processor.compiler_options,
      stubs:            Opal::Processor.stubbed_files,
      path_reader:      Opal::PathReader.new(path_finder),
    )

    builder.build 'opal'
    builder.build 'opal-rspec'
    spec_files.each do |spec_file|
      file = File.new spec_file
      builder.build_str file.read, spec_file
    end
    builder.build_str 'Opal::RSpec::Runner.autorun', '(exit)'
    # builder.build_str 'exit', '(exit)'

    render js: builder.to_s
  end




  private

  def clean_spec_path(path)
    path.split("#{spec_location}/").flatten.last.gsub(/(\.rb|\.opal)/, '')
  end

  def spec_files
    @spec_files ||= some_spec_files || all_spec_files
  end

  def pattern
    params[:pattern]
  end

  def some_spec_files
    return if pattern.blank?
    pattern.split(':').map { |path| spec_files_for_glob(path) }.flatten
  end

  def all_spec_files
    spec_files_for_glob '**/*_spec{.js,}'
  end

  def spec_files_for_glob glob = '**'
    Dir[Rails.root.join("#{spec_location}/#{glob}.{rb,opal}")]
  end

  def spec_location
    Rails.application.config.opal.spec_location
  end
end
