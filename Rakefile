require 'rake/testtask'
require 'pty'

Rake::TestTask.new do |t|
  t.libs << 'test'
end

desc "Run tests"
task :default => :test

namespace 'fetch' do
  desc "Download BOE-A files"
  task :pardons, :year do |t, args|
    puts "Download BOE-A files for year #{args.year} ..."
    begin
      PTY.spawn("#{File.dirname(__FILE__)}/fetch.rb #{args.year}") do |stdin, stdout, pid|
        stdin.each { |line| puts line }
      end
    rescue PTY::ChildExited
      puts "The child process exited!"
    end
  end
end
