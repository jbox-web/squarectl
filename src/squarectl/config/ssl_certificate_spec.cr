module Squarectl
  module Config
    # :nodoc:
    class SSLCertificateSpec
      include JSON::Serializable
      include YAML::Serializable

      property domain : String
      property cert_path : String
      property key_path : String

      def to_h(environment)
        {
          "domain"    => domain,
          "cert_path" => build_certificates_path(cert_path, environment),
          "key_path"  => build_certificates_path(key_path, environment),
        }
      end

      private def build_certificates_path(file, environment)
        if file.starts_with?("/")
          file
        else
          environment.root_dir.join(file).to_s
        end
      end
    end
  end
end
