module Pubgen
  module NCX
    def self.generate(title, toc, uuid)
      # header
      toc_xml = <<EOF
<?xml version='1.0' encoding='utf-8'?>
<ncx xmlns="http://www.daisy.org/z3986/2005/ncx/" version="2005-1" \
xml:lang="en">
  <head>
    <meta content="#{uuid}" name="dtb:uid"/>
    <meta content="2" name="dtb:depth"/>
    <meta content="pubgen" name="dtb:generator"/>
    <meta content="0" name="dtb:totalPageCount"/>
    <meta content="0" name="dtb:maxPageNumber"/>
  </head>
  <docTitle>
    <text>#{CGI.escapeHTML(title || '')}</text>
  </docTitle>
  <navMap>
EOF
      # NavPoint traces indentation, so we need class and instantiation of it
      nav_point = NavPointImpl.new
      toc.each do |name_and_path|
        toc_xml += nav_point.generate(name_and_path)
      end
      # footer
      toc_xml += "  </navMap>\n</ncx>"
    end

    # define NavPointImpl class
    # it's private. only Pubgen.NCX.generate use it
    class NavPointImpl
      private
      def generate_impl(name_and_path, depth)
        header = <<EOF
    <navPoint id="d%03d" playOrder="%d">
      <navLabel>
        <text>%s</text>
      </navLabel>
      <content src="%s"/>
EOF
        footer = "    </navPoint>\n"
        if depth
          depth.times do
            header.gsub!(/^/, '  ')
            footer.gsub!(/^/, '  ')
          end
        end

        @play_order += 1
        navpoint_xml = ''
        if name_and_path.is_a?(String)
          if name_and_path.split(" -- ").size != 2
            raise "Bad toc contents format: " + name_and_path 
          end
          navpoint_xml = header % [@play_order, @play_order, 
            CGI.escapeHTML(name_and_path.split(" -- ")[0]), 
            name_and_path.split(" -- ")[1]]
        else
          # if not string, it's hash map with just one element
          name_and_path.each do |key, value|
            if key.split(" -- ").size != 2
              raise "Bad toc contents format: " + key 
            end
            navpoint_xml = header % [@play_order, @play_order, 
              CGI.escapeHTML(key.split(" -- ")[0]), key.split(" -- ")[1]]
            value.each do |v|
              navpoint_xml += generate_impl(v, depth + 1)
            end
          end
        end

        navpoint_xml += footer
      end

      public
      def initialize
        @play_order = 0
      end

      def generate(name_and_path)
        generate_impl(name_and_path, 0)
      end
    end
  end
end
