ENV["BRANCH_KEY"] = "key_test_ngn27ouyf8yBVhq5kffg7ncfErc7cISG"
ENV["BRANCH_SECRET"] = "secret_test_6L2X9Pt3k07Tn6HW3sKcR3VZFkklISYY"

describe BranchIO::Client do
  describe "#initialize" do
    it "should raise an exception if no branch key is provided" do
      expect do
        BranchIO::Client.new(nil)
      end.to raise_error(BranchIO::Client::ErrorMissingBranchKey)
    end

    it "should try to load the branch key from the BRANCH_KEY envorionemnt variable" do
      allow(ENV).to receive(:[]).with("BRANCH_KEY").and_return("12345")
      allow(ENV).to receive(:[]).with("BRANCH_SECRET").and_return("666")

      client = BranchIO::Client.new

      expect(client.branch_key).to eq("12345")
      expect(client.branch_secret).to eq("666")
    end
  end

  describe BranchIO::Client::Links do
    let(:client) { BranchIO::Client.new }
    around do |example|
      VCR.use_cassette('branch-io', record: :new_episodes,
                       match_requests_on: [:method, :uri, :body]) { example.run }
    end

    describe "#link!" do
      it "calls #link" do
        res = double(validate!: true)
        expect(client).to receive(:link).and_return(res)
        client.link!
      end

      it "raises if the result is a failure" do
        res = BranchIO::Client::ErrorResponse.new(double(success?: false))
        expect(client).to receive(:link).and_return(res)

        expect do
          client.link!
        end.to raise_error(BranchIO::Client::ErrorApiCallFailed)
      end
    end

    describe "#link" do
      describe "with no option" do
        it "succeeds" do
          pending unless ENV["BRANCH_KEY"]

          # Create a new link
          res = client.link

          # It should be successbul
          expect(res).not_to be_nil
          expect(res).to be_success
        end

        it "creates a new deep link" do
          pending unless ENV["BRANCH_KEY"]

          # Create a new link
          res = client.link

          # It should be successbul
          expect(res).to be_kind_of(BranchIO::Client::UrlResponse)
          expect(res.url).not_to be_nil
        end
      end

      describe "with options" do
        it "succeeds" do
          pending unless ENV["BRANCH_KEY"]

          # Create a new link
          res = client.link(
            tags: ["test"],
            channel: "test",
            feature: "spec",
            stage: "test",
            data: {
                value: 42
            }
          )

          # It should be successbul
          expect(res).not_to be_nil
          expect(res).to be_success
        end
      end

      describe "with a LinkProperties instance" do
        it "succeeds" do
          pending unless ENV["BRANCH_KEY"]

          # Create a new link properties object
          props = BranchIO::LinkProperties.new(
            tags: ["test"],
            channel: "test",
            feature: "spec",
            stage: "test",
            data: {
                value: 42
            }
          )

          # Pass the configuration object to the call
          res = client.link(props)

          # It should be successbul
          expect(res).not_to be_nil
          expect(res).to be_success
        end
      end
    end

    describe "#links!" do
      it "calls #links" do
        res = double(validate!: true)
        expect(client).to receive(:links).and_return(res)
        client.links!
      end
    end

    describe "#links" do
      describe "with no option" do
        it "fails" do
          pending unless ENV["BRANCH_KEY"]

          # Create a new link
          res = client.links

          # It should be successbul
          expect(res).not_to be_nil
          expect(res).not_to be_success
        end
      end
      describe "with valid options" do
        it "succeeds" do
          pending unless ENV["BRANCH_KEY"]

          # Create a new link
          res = client.links([
                               {
                                  channel: "test"
                               },
                               {
                                 channel: "test"
                               }
                             ])

          # It should be successbul
          expect(res).not_to be_nil
          expect(res).to be_success

          # It returns all the urls at once
          expect(res.urls).to be_kind_of(Array)
          expect(res.urls.count).to eq(2)
        end
      end
    end

    describe "#link_info!" do
      it "calls #link_info" do
        res = double(validate!: true)
        expect(client).to receive(:link_info).and_return(res)
        client.link_info!
      end
    end

    describe "#link_info" do
      let!(:url) { client.link(channel: "code", feature: "test", tags: ["test"]).url }

      it "succeeds" do
        expect(client.link_info(url)).to be_success
      end

      it "returns the link properties from the server" do
        props = client.link_info(url).link_properties

        expect(props.channel).to eq("code")
        expect(props.feature).to eq("test")
        expect(props.tags).to eq(["test"])
      end
    end

    describe "#update_link!" do
      it "calls #update_link" do
        res = double(validate!: true)
        expect(client).to receive(:update_link).and_return(res)
        client.update_link!
      end
    end

    describe "#update_link" do
      let!(:url) { client.link(channel: "code", feature: "test", tags: ["test", "test-update"]).url }

      it "succeeds" do
        expect(
          client.update_link(url, channel: "retest")
        ).to be_success
      end

      it "updates the link properties from the server" do
        client.update_link(url, channel: "retest")
        props = client.link_info(url).link_properties
        expect(props.channel).to eq("retest")
      end
    end
  end # /Client

  describe BranchIO::Client::Events do
    let(:client) { BranchIO::Client.new }
    around do |example|
      VCR.use_cassette('branch-io', record: :new_episodes,
                       match_requests_on: [:method, :uri, :body]) { example.run }
    end

    describe "#log_standard_event" do
      describe "with no option" do
        it "fails" do
          pending unless ENV["BRANCH_KEY"]

          res = client.log_standard_event

          expect(res).not_to be_nil
          expect(res).to be_failure
        end
      end

      describe "with incomplete options" do
        it "fails" do
          pending unless ENV["BRANCH_KEY"]

          user_data = {
            environment: "FULL_APP"
          }
          event_data = {
            currency: "USD",
            shipping: 5,
            tax: 0,
            revenue: 35,
            transaction_id: "Order-11"
          }
          body = {
            name: "PURCHASE",
            user_data: user_data,
            event_data: event_data
          }

          res = client.log_standard_event(body)

          expect(res).not_to be_nil
          expect(res).to be_failure
        end
      end

      describe "with correct options" do
        it "succeeds" do
          pending unless ENV["BRANCH_KEY"]

          user_data = {
            os: "iOS",
            os_version: "11.0.1",
            environment: "FULL_APP",
            developer_identity: "1",
            app_version: "1.0.1"
          }
          content_items = [
            {
              "$content_schema"   => "COMMERCE_PRODUCT",
              "$price"            => 100,
              "$quantity"         => 2,
              "$sku"              => "112320",
              "$product_name"     => "Domaine de la Romanee-Conti Romanee-Conti Grand Cru 1990.",
              "$product_category" => "FOOD_BEVERAGES_AND_TOBACCO",
              "$product_variant"  => "750ml Current Vintage"
            }
          ]
          event_data = {
            currency: "USD",
            shipping: 5,
            tax: 0,
            revenue: 35,
            transaction_id: "Order-11"
          }
          custom_data = {
            purchase_location: "Joes Liquor Barn",
            store_pickup: "unavailable"
          }
          body = {
            name: "PURCHASE",
            user_data: user_data,
            custom_data: custom_data,
            event_data: event_data,
            content_items: content_items,
            metadata: {}
          }

          res = client.log_standard_event(body)

          expect(res).not_to be_nil
          expect(res).to be_success
        end
      end

      describe "with a EventProperties instance" do
        it "succeeds" do
          pending unless ENV["BRANCH_KEY"]

          user_data = {
            os: "Android",
            os_version: "4.0.0",
            environment: "FULL_APP",
            developer_identity: "1",
            app_version: "1.0.1"
          }
          event_data = {
            currency: "USD",
            shipping: 5,
            tax: 0,
            revenue: 35,
            transaction_id: "Order-11"
          }
          body = {
            name: "PURCHASE",
            user_data: user_data,
            event_data: event_data
          }

          # Create a new event properties object
          props = BranchIO::EventProperties.new(body)

          # Pass the configuration object to the call
          res = client.log_standard_event(props)

          # It should be successful
          expect(res).not_to be_nil
          expect(res).to be_success
        end
      end

      describe "with invalid event name" do
        it "fails" do
          pending unless ENV["BRANCH_KEY"]

          user_data = {
            os: "iOS",
            os_version: "11.0.1",
            environment: "FULL_APP",
            developer_identity: "1",
            app_version: "1.0.1"
          }
          content_items = [
            {
              "$content_schema"   => "COMMERCE_PRODUCT",
              "$price"            => 100,
              "$quantity"         => 2,
              "$sku"              => "112320",
              "$product_name"     => "Domaine de la Romanee-Conti Romanee-Conti Grand Cru 1990.",
              "$product_category" => "FOOD_BEVERAGES_AND_TOBACCO",
              "$product_variant"  => "750ml Current Vintage"
            }
          ]
          event_data = {
            currency: "USD",
            shipping: 5,
            tax: 0,
            revenue: 35,
            transaction_id: "Order-11"
          }
          custom_data = {
            purchase_location: "Joes Liquor Barn",
            store_pickup: "unavailable"
          }
          body = {
            name: "RANDOM_EVENT_NAME",
            user_data: user_data,
            custom_data: custom_data,
            event_data: event_data,
            content_items: content_items,
            metadata: {}
          }

          res = client.log_standard_event(body)

          expect(res).not_to be_nil
          expect(res).to be_failure
        end
      end
    end

    describe "#log_custom_event" do
      describe "with no option" do
        it "fails" do
          pending unless ENV["BRANCH_KEY"]

          res = client.log_custom_event

          expect(res).not_to be_nil
          expect(res).to be_failure
        end
      end

      describe "with correct options" do
        it "succeeds" do
          pending unless ENV["BRANCH_KEY"]

          user_data = {
            os: "iOS",
            os_version: "11.0.1",
            environment: "FULL_APP",
            developer_identity: "1",
            app_version: "1.0.1"
          }
          custom_data = {
            picture_location: "Joes Liquor Barn"
          }
          body = {
            name: "TAKING PICTURE",
            user_data: user_data,
            custom_data: custom_data
          }

          res = client.log_custom_event(body)

          expect(res).not_to be_nil
          expect(res).to be_success
        end
      end
    end
  end # /Client
end
