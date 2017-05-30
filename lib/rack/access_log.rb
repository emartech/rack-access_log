require 'rack/access_log/version'
require 'rack'
require 'benchmark'

module Rack
  class AccessLog
    def initialize(app, logger, config = {})
      @app = app
      @logger = logger
      configure!(config)
    end

    def call(env)
      status, header, body_lines, realtime = next_middleware_call_with_benchmarking(env)
      @logger.info(create_log_message(env, status, realtime)) if tracked?(env)
      [status, header, body_lines]
    end

    private

    def tracked?(env)
      !@exclude_paths.include?(env[Rack::PATH_INFO])
    end

    def create_log_message(env, status, realtime)
      {
        execution_time_sec: realtime,
        remote_ip: remote_ip_by(env),
        request_method: env[Rack::REQUEST_METHOD],
        request_path: env[Rack::PATH_INFO],
        query_string: env[Rack::QUERY_STRING],
        response_status_code: status.to_i
      }
    end

    def remote_ip_by(env)
      env['HTTP_X_FORWARDED_FOR'] || env['REMOTE_ADDR'] || '-'
    end

    def next_middleware_call_with_benchmarking(env)
      status = nil
      header = nil
      body_lines = nil
      realtime = Benchmark.realtime do
        status, header, body_lines = @app.call(env)
      end
      [status, header, body_lines, realtime]
    end

    def configure!(config)
      @exclude_paths = [config.delete(:exclude_path)].flatten.compact.freeze
      check_for_unrequired_options(config)
    end

    def check_for_unrequired_options(config)
      invalid_config_options = config.keys
      raise("invalid config: #{invalid_config_options.join(', ')}") unless invalid_config_options.empty?
    end
  end
end
