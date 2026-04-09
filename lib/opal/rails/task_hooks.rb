# frozen_string_literal: true

require 'rake'

module Opal
  module Rails
    module TaskHooks
      module_function

      BUILD_HOOKS = [
        'assets:precompile',
        'test:prepare',
        'spec:prepare'
      ].freeze

      # Ensure `rake test` invokes test:prepare (which Rails defines but
      # does not wire as a prerequisite of the :test task).
      PREPARE_HOOKS = {
        'test' => 'test:prepare',
        'spec' => 'spec:prepare'
      }.freeze

      CLOBBER_HOOKS = [
        'assets:clobber'
      ].freeze

      def apply!(task_manager: Rake::Task)
        BUILD_HOOKS.each do |task_name|
          attach(task_name, prerequisite: 'opal:build', task_manager: task_manager)
        end
        CLOBBER_HOOKS.each do |task_name|
          attach(task_name, prerequisite: 'opal:clobber', task_manager: task_manager)
        end
        PREPARE_HOOKS.each do |task_name, prerequisite|
          attach(task_name, prerequisite: prerequisite, task_manager: task_manager)
        end
      end

      def attach(task_name, prerequisite:, task_manager: Rake::Task)
        return unless task_manager.task_defined?(task_name)

        task = task_manager[task_name]
        return if task.prerequisites.include?(prerequisite)

        task.enhance([prerequisite])
      end
    end
  end
end
