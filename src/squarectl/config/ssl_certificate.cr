module Squarectl
  module Config
    # A group of SSL certificate specs to generate (via `mkcert`) before `up`,
    # scoped to one or more targets.
    #
    # :nodoc:
    class SSLCertificate
      include JSON::Serializable
      include YAML::Serializable

      property target : String | Array(String) = "compose"
      property ssl_certificates : Array(SSLCertificateSpec) = [] of SSLCertificateSpec
    end
  end
end
