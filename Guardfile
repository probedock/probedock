# A sample Guardfile
# More info at https://github.com/guard/guard#readme

resque_pool_command = 'bundle exec resque-pool --environment development RESQUE=1'
guard :process, name: 'Resque Pool', command: resque_pool_command, stop_signal: 'QUIT' do
  watch %r{^app/(.+)\.rb$}
  watch %r{^lib/(.+)\.rb$}
  watch %r{^config/resque-pool\.yml$}
end
