#!/usr/bin/env ruby

require 'xcodeproj'
require 'pathname'

# Open the project
project_path = 'Leader Key.xcodeproj'
project = Xcodeproj::Project.open(project_path)

# Get the main target
target = project.targets.find { |t| t.name == 'Leader Key' }
if target.nil?
  puts "Error: Could not find target 'Leader Key'"
  exit 1
end

# Get the main group
main_group = project.main_group['Leader Key']
if main_group.nil?
  puts "Error: Could not find 'Leader Key' group"
  exit 1
end

# Files to add
files_to_add = [
  'InputMethod.swift',
  'CGEventTapInputMethod.swift',
  'KarabinerInputMethod.swift',
  'UnixSocketServer.swift',
  'LeaderKeyProfile.swift',
  'ProfileManagementSheet.swift'
]

# Add each file
files_to_add.each do |filename|
  file_path = "Leader Key/#{filename}"
  
  # Check if file exists
  unless File.exist?(file_path)
    puts "Warning: File #{file_path} does not exist"
    next
  end
  
  # Check if file is already in project
  existing = main_group.files.find { |f| f.path == filename }
  if existing
    puts "File #{filename} is already in the project"
    next
  end
  
  # Add file reference
  file_ref = main_group.new_file(filename)
  
  # Add to build phase
  target.source_build_phase.add_file_reference(file_ref)
  
  puts "Added #{filename} to project"
end

# Save the project
project.save

puts "Project updated successfully!"