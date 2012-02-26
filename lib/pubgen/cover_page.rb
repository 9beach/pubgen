module Pubgen
  module CoverPage
    def self.need_to_generate?(guide)
      guide['cover-image'] != nil && guide['cover-page'] == nil
    end

    def self.generate(cover_image)
      <<EOF
<?xml version='1.0' encoding='utf-8'?>
<html xmlns="http://www.w3.org/1999/xhtml" xml:lang="en">
  <head>
    <meta http-equiv="Content-Type" content="text/html; charset=UTF-8"/>
    <meta name="pubgen:cover" content="true"/>
    <title>Cover</title>
    <style type="text/css" title="override_css">
      @page {padding: 0pt; margin:0pt}
      body { text-align: center; padding:0pt; margin: 0pt; }
    </style>
  </head>
  <body>
    <div>
      <svg xmlns="http://www.w3.org/2000/svg" xmlns:xlink="http://www.w3.org/1999/xlink" version="1.1" width="100%" height="100%" viewBox="0 0 469 616" preserveAspectRatio="xMinYMin">
        <image width="469" height="616" xlink:href="#{cover_image}"/>
      </svg>
    </div>
  </body>
</html>
EOF
    end
  end
end
