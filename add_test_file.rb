#!/usr/bin/env ruby

require 'xcodeproj'
require 'pathname'

if ARGV.length < 2
  puts "Usage: ruby add_test_file.rb <file_path> <target_name>"
  exit 1
end

file_path = ARGV[0]
target_name = ARGV[1]
project_path = 'Leader Key.xcodeproj'
project = Xcodeproj::Project.open(project_path)

target = project.targets.find { |t| t.name == target_name }
if target.nil?
  puts "Error: Could not find target '#{target_name}'"
  exit 1
end

# Find or create the group
group_path = File.dirname(file_path)
# Split path into components and traverse/create groups
current_group = project.main_group
group_path.split('/').each do |component|
  next if component == '.'
  existing = current_group.children.find { |c| c.name == component || c.path == component }
  if existing
    current_group = existing
  else
    current_group = current_group.new_group(component)
  end
end

filename = File.basename(file_path)
# Check if file already exists in group
existing_file = current_group.files.find { |f| f.path == filename }

if existing_file
  puts "File #{filename} already exists in group, adding to target if needed"
  file_ref = existing_file
else
  file_ref = current_group.new_file(filename)
end

# Add to target
if target.source_build_phase.files_references.include?(file_ref)
  puts "File already in build phase"
else
  target.add_file_references([file_ref])
  puts "Added #{file_path} to #{target_name}"
end

project.save
