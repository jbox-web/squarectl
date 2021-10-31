module Squarectl
  module Commands
    module SSLCertificates
      def create_ssl_certificates
        ssl_certificates.each do |ssl_cert|
          create_ssl_certificate(ssl_cert)
        end
      end

      def create_ssl_certificate(ssl_cert)
        domain_name = ssl_cert["domain"]
        cert_path = ssl_cert["cert_path"]
        key_path = ssl_cert["key_path"]

        if !File.exists?(cert_path) && !File.exists?(key_path)
          puts "Generating SSL certificate for : #{domain_name}"

          FileUtils.mkdir_p(File.dirname(cert_path))

          args = ["--cert-file", cert_path, "--key-file", key_path, domain_name]

          @executor.run_command("mkcert", args: args)
          @executor.run_command("mkcert", args: ["-install"])
        else
          puts "SSL certificate already exist for #{domain_name}"
        end
      end

      def destroy_ssl_certificates
        ssl_certificates.each do |ssl_cert|
          destroy_ssl_certificate(ssl_cert)
        end
      end

      def destroy_ssl_certificate(ssl_cert)
        cert_path = ssl_cert["cert_path"]
        key_path = ssl_cert["key_path"]

        FileUtils.rm(cert_path) if File.exists?(cert_path)
        FileUtils.rm(key_path) if File.exists?(key_path)
      end
    end
  end
end
