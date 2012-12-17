require 'rake/testtask'
require 'pty'

Rake::TestTask.new do |t|
  t.libs << 'test'
end

desc "Run tests"
task :default => :test


task :with_defaults, :arg1, :arg2 do |t, args|
  args.with_defaults(:arg1 => :default_1, :arg2 => :default_2)
  puts "Args with defaults were: #{args}"
end
namespace 'parse' do
  desc "Extract pardons from BOE files"
  #task :pardons, [:year] do |t, args|
  task :pardons, :year, :path do |t, args|
    puts "Parsing pardons for year #{args.year} on path \"#{args.path}/\" ..."
    begin
      PTY.spawn("#{File.dirname(__FILE__)}/parse_pardons.rb #{args.year} #{args.path}") do |stdin, stdout, pid|
        stdin.each { |line| puts line }
      end
    rescue PTY::ChildExited
      puts "The child process exited!"
    end
    
  end
end