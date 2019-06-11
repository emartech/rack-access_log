RSpec.describe Rack::AccessLog do
  subject(:middleware) { described_class.new(next_middleware, logger, middleware_config) }

  it 'has a version number' do
    expect(Rack::AccessLog::VERSION).not_to be nil
  end

  let(:next_middleware_logic) { proc { |_env| } }
  let(:next_middleware) do
    lambda do |env|
      benchmark_result[:realtime] = expected_realtime
      next_middleware_logic.call(env)
      next_middleware_response
    end
  end
  let(:next_middleware_response) { Rack::Response.new.finish }
  let(:logger) { double(:Logger).as_null_object }
  let(:middleware_config) { {} }

  let(:uri) { '/rspec/test/uri?k=v' }
  let(:options) { { :method => 'GET' } }
  let(:env) { Rack::MockRequest.env_for(uri, options) }

  let(:benchmark_result) { { :realtime => nil } }
  let(:expected_realtime) { 365 * 24 * 60 * 60 }
  before do
    allow(Benchmark).to receive(:realtime) do |&block|
      block.call
      benchmark_result[:realtime]
    end
  end

  describe '#call' do
    subject(:after_call) { middleware.call(env) }

    it { is_expected.to eq next_middleware_response }

    it { expect { after_call }.to log_with logger, :info, hash_including(execution_time_sec: expected_realtime) }
    it { expect { after_call }.to log_with logger, :info, hash_including(request_method: 'GET') }
    it { expect { after_call }.to log_with logger, :info, hash_including(request_path: '/rspec/test/uri') }
    it { expect { after_call }.to log_with logger, :info, hash_including(query_string: 'k=v') }
    it { expect { after_call }.to log_with logger, :info, hash_including(response_status_code: 200) }

    describe 'exclude_path option' do
      before { middleware_config[:exclude_path] = '/rspec/test/uri' }

      it 'not logs any log because the request path is exluded' do
        expect(logger).to_not receive(:info)

        after_call
      end
    end

    describe 'remote_ip' do
      context 'when HTTP_X_FORWARDED_FOR given' do
        before { env['HTTP_X_FORWARDED_FOR'] = 'forwarded-ip-addr' }

        it { expect { after_call }.to log_with logger, :info, hash_including(remote_ip: 'forwarded-ip-addr') }
      end

      context 'when REMOTE_ADDR given' do
        before { env['REMOTE_ADDR'] = 'remote-ip-addr' }

        it { expect { after_call }.to log_with logger, :info, hash_including(remote_ip: 'remote-ip-addr') }
      end

      context 'when nothing specifies remote addr' do
        before { %w[REMOTE_ADDR HTTP_X_FORWARDED_FOR].each { |env_key| env.delete(env_key) } }

        it { expect { after_call }.to log_with logger, :info, hash_including(remote_ip: '-') }
      end
    end

    context 'when env values changed during the next middleware call' do
      let(:next_middleware_logic) do
        lambda do |env|
          env['PATH_INFO'] = '/cat'
          env['REQUEST_METHOD'] = 'NOPE_TRACE'
          env['QUERY_STRING'] = 'q=no'
          env['REMOTE_ADDR'] = 'yo mama!'
        end
      end

      it { expect { after_call }.to log_with logger, :info, hash_including(request_method: 'GET') }
      it { expect { after_call }.to log_with logger, :info, hash_including(request_path: '/rspec/test/uri') }
      it { expect { after_call }.to log_with logger, :info, hash_including(query_string: 'k=v') }
      it { expect { after_call }.to log_with logger, :info, hash_including(remote_ip: '-') }

      context "and a not tracked path changes it's path_info" do
        before { middleware_config[:exclude_path] = env[Rack::PATH_INFO] }

        it { expect(logger).to_not receive(:info); after_call }
      end
    end
  end
end
