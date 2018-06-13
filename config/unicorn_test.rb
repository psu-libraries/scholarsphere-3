# frozen_string_literal: true

worker_processes 3

# By default, the Unicorn logger will write to stderr.
# Additionally, one applications/frameworks log to stderr or stdout,
# so prevent them from going to /dev/null when daemonized here:
stderr_path 'log/unicorn.stderr.log'
stdout_path 'log/unicorn.stdout.log'
