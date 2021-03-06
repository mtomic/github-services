require File.expand_path('../helper', __FILE__)

class FlowdockTest < Service::TestCase
  def setup
    @stubs = Faraday::Adapter::Test::Stubs.new
    @tokens = "token1,token2"
  end

  def test_push
    @tokens.to_s.split(",").each do |t|
      @stubs.post "/v1/github/#{t}" do |env|
        assert_match /json/, env[:request_headers]['content-type']
        assert_equal push_payload, JSON.parse(env[:body])
        [200, {}, '']
      end
    end

    svc = service(
      {'token' => @tokens}, push_payload)
    svc.receive_event
  end

  def test_token_sanitization
    @tokens.to_s.split(",").each do |t|
      @stubs.post "/v1/github/#{t}" do |env|
        assert_equal payload, JSON.parse(env[:body])
        [200, {}, '']
      end
    end

    svc = service(
      {'token' => " " + @tokens + " "}, payload)
    svc.receive_event
  end

  def service(*args)
    super Service::Flowdock, *args
  end
end

