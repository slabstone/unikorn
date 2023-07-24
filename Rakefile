# frozen_string_literal: true

require 'rubocop/rake_task'
require 'reek/rake/task'

RuboCop::RakeTask.new
Reek::Rake::Task.new

desc 'Run linters'
task lint: %i[rubocop reek]

desc 'Run linters'
task default: :lint
