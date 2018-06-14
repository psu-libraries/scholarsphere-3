# frozen_string_literal: true

HTTP_PORT = '4000'

test_instance_pid = fork do
  exec "unicorn_rails -E test -p #{HTTP_PORT} -c #{Rails.root.join('config', 'unicorn_test.rb')}"
end

at_exit do
  Process.kill 'INT', test_instance_pid
  Process.wait
end
