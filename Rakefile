require 'rake/testtask'
require 'pty'

Rake::TestTask.new do |t|
  t.libs << 'test'
end

desc "Run tests"
task :default => :test

namespace 'parse' do
  desc "Extract pardons from BOE files"
  task :pardons, [:year] do |t, args|
    puts "Parsing pardons for year #{args.year}..."
    begin
      PTY.spawn("#{File.dirname(__FILE__)}/parse_pardons.rb #{args.year}") do |stdin, stdout, pid|
        stdin.each { |line| puts line }
      end
    rescue PTY::ChildExited
      puts "The child process exited!"
    end
    
  end
end