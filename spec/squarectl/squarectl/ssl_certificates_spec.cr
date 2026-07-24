require "../../spec_helper.cr"

Spectator.describe Squarectl::Commands::SSLCertificates do
  before_each { Squarectl.load_config("spec/fixtures/config/complex.yml") }

  mock Squarectl::Executor

  let(executor) { mock(Squarectl::Executor) }
  let(environment_object) { Squarectl.find_environment(environment: "staging", target: "compose") }
  let(task) { Squarectl::TaskFactory.build("compose", environment_object, Squarectl.environment_all, executor) }

  describe "#create_ssl_certificate" do
    it "regenerates when the certificate exists but its key is missing" do
      dir = File.tempname
      FileUtils.mkdir_p(dir)
      cert = File.join(dir, "c.crt")
      key = File.join(dir, "c.key")
      File.write(cert, "existing cert") # cert present, key absent

      ssl_cert = {"domain" => "d.local", "cert_path" => cert, "key_path" => key}

      begin
        expect(executor).to receive(:run_command).with("mkcert", ["--cert-file", cert, "--key-file", key, "d.local"]).and_return(true)
        expect(executor).to receive(:run_command).with("mkcert", ["-install"]).and_return(true)

        task.create_ssl_certificate(ssl_cert)
      ensure
        FileUtils.rm_rf(dir)
      end
    end
  end
end
