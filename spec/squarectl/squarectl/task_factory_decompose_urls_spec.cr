require "../../spec_helper.cr"

Spectator.describe Squarectl::TaskFactory do
  describe ".decompose_urls" do
    it "leaves keys that do not end with _URL untouched" do
      result = Squarectl::TaskFactory.decompose_urls({"TRAEFIK_DOMAIN" => "traefik.local"})
      expect(result).to eq({"TRAEFIK_DOMAIN" => "traefik.local"})
    end

    it "expands a *_URL key into _DOMAIN and _SCHEME while keeping the original" do
      result = Squarectl::TaskFactory.decompose_urls({"BACK_OFFICE_URL" => "https://back.local"})
      expect(result).to eq({
        "BACK_OFFICE_URL"    => "https://back.local",
        "BACK_OFFICE_DOMAIN" => "back.local",
        "BACK_OFFICE_SCHEME" => "https",
      })
    end

    it "does not crash on a *_URL value missing a host or scheme" do
      result = Squarectl::TaskFactory.decompose_urls({"API_URL" => "not_a_url"})
      expect(result).to eq({"API_URL" => "not_a_url"})
    end
  end
end
