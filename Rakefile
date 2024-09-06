# frozen_string_literal: true

require 'bundler'
require 'rspec/core/rake_task'
require 'rubocop/rake_task'

task default: %i[spec rubocop]

module Bundler
  # Monkey patch bundler tasks to remove the hard coded "v" between the tag
  # prefix and the version number.
  class GemHelper
    def version_tag
      "#{@tag_prefix}#{version}"
    end
  end
end

Bundler::GemHelper.install_tasks

RuboCop::RakeTask.new(:rubocop) do |task|
  task.requires << 'rubocop'
end

RSpec::Core::RakeTask.new(:spec)
