describe "pinging the target" do
  it "fetches content from target" do
    resp = stub("response")
    http_client = stub("http_client")
    http_client.should_receive(:fetch).with("SOME-URL").and_return(resp)

    w = WatchDog.new("SOME-URL", http_client, stub("policy").as_null_object)
    w.ping
  end

  it "passes the received content to a policy object" do
    policy = stub("policy")
    policy.should_receive(:new_content).with(5000)

    http_client = stub("http_client")
    http_client.should_receive(:fetch).and_return(5000)

    w = WatchDog.new("SOME-URL", http_client, policy)
    w.ping

    # At this point the tests are green and things are looking good. However,
    # there's some duplication between the two text examples - more than the
    # amount I am comofrtable with. I am suspecting the design is not
    # adequate/the steps are not babysteps.
  end
end

class WatchDog
  def initialize(url, http_client, policy)
    @url = url
    @http_client = http_client
    @policy = policy
  end

  def ping
    @policy.new_content(@http_client.fetch(@url))
  end
end
