module Pubgen
  module Container
    # Returns the OPF file path.
    def self.opf_path
      'content.opf'
    end

    # Generates the container XML. It contains the OPF file path.
    def self.generate
      <<EOF
<?xml version="1.0"?>
<container version="1.0" xmlns="urn:oasis:names:tc:opendocument:xmlns:\
container">
  <rootfiles>
    <rootfile full-path="#{opf_path}" media-type="application/\
oebps-package+xml"/>
  </rootfiles>
</container>
EOF
    end
  end
end
