module Squarectl
  module Config
    # :nodoc:
    class SSLCertificate
      include JSON::Serializable
      include YAML::Serializable

      property target : String | Array(String) = "compose"
      property ssl_certificates : Array(SSLCertificateSpec) = [] of SSLCertificateSpec
    end
  end
end
