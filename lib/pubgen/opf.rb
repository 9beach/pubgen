require 'cgi'

module Pubgen
  module OPF
    def self.ncx_path
      'toc.ncx'
    end

    def self.generate(yaml, uuid)
      cover_id, manifest_xml, file2id = 
        OPFImpl.get_cover_id_and_manifest_xml(yaml['guide']['cover-image'], 
                                              yaml['manifest'])
      metadata_xml = OPFImpl.get_metadata_xml(yaml['metadata'], uuid, cover_id)
      spine_xml = OPFImpl.get_spine_xml(yaml['spine'], file2id)
      guide_xml = OPFImpl.get_guide_xml(yaml['guide'], file2id)

      <<EOF
<?xml version='1.0' encoding='utf-8'?>
<package xmlns="http://www.idpf.org/2007/opf" version="2.0" \
unique-identifier="uuid_id">
#{metadata_xml}#{manifest_xml}#{spine_xml}#{guide_xml}</package>
EOF
    end

    # sub directories and relative paths
    def self.valid_manifest_element?(e)
      e[0..2] != "../" && e[0] != "/"
    end

    # define OPFImpl class
    # it's private. only Pubgen.OPF.generate use it
    module OPFImpl
      def self.guess_media_type(filename)
        case filename.downcase
        when /.*\.x?html?$/
          'application/xhtml+xml'
        when /.*\.css$/
          'text/css'
        when /.*\.(jpeg|jpg)$/
          'image/jpeg'
        when /.*\.png$/
          'image/png'
        when /.*\.gif$/
          'image/gif'
        when /.*\.svg$/
          'image/svg+xml'
        when /.*\.ncx$/
          'application/x-dtbncx+xml'
        when /.*\.opf$/
          'application/oebps-package+xml'
        else
          'application/octet-stream'
        end
      end

      def self.get_cover_id_and_manifest_xml(cover_path, manifest)
        no = 1;
        manifest_xml = "  <manifest>\n"
        cover_id = nil
        file2id = {}

        manifest.each do |path|
          if OPF.valid_manifest_element?(path) == false
            raise "A manifest file, #{path} is not in sub-directory of " + 
                  "yaml file"
          end
          id = "i%03d" % no
          manifest_xml << "    <item id=\"#{id}\" href=\"#{path}\" " + 
                          "media-type=\"#{guess_media_type(path)}\"/>\n"
          if path == cover_path
            cover_id = id
          end
          file2id[path] = id

          no += 1
        end

        if cover_path && cover_id == nil
          raise "Failed to find cover-image from manifest" 
        end

        manifest_xml << "    <item id=\"ncx\" href=\"#{OPF.ncx_path}\" " + 
                "media-type=\"application/x-dtbncx+xml\"/>\n  </manifest>\n"

        return cover_id, manifest_xml, file2id
      end

      def self.cgi_escape(text)
        CGI.escapeHTML(text || '')
      end

      def self.get_metadata_xml(metadata, uuid, cover_id)
        cover_id_xml = ''
        if cover_id != nil
          cover_id_xml = "\n    <meta name=\"cover\" content=\"#{cover_id}\"/>"
        end
        <<EOF
  <metadata xmlns:dc="http://purl.org/dc/elements/1.1/" \
xmlns:opf="http://www.idpf.org/2007/opf">
    <dc:title>#{cgi_escape(metadata['title'])}</dc:title>
    <dc:creator opf:role="aut">#{cgi_escape(metadata['creator'])}\
</dc:creator>
    <dc:date>#{cgi_escape((metadata['date'].is_a?(Fixnum) ? \
metadata['date'].to_s : metadata['date']))}</dc:date>
    <dc:language>#{cgi_escape(metadata['language'])}</dc:language>
    <dc:subject>#{cgi_escape(metadata['subject'])}</dc:subject>
    <dc:publisher>#{cgi_escape(metadata['publisher'])}</dc:publisher>
    <dc:description>#{cgi_escape(metadata['description'])}</dc:description>
    <dc:contributor opf:role="bkp">#{cgi_escape(metadata['contributor'])}\
</dc:contributor>
    <dc:source>#{cgi_escape(metadata['source'])}</dc:source>
    <dc:rights>#{cgi_escape(metadata['rights'])}</dc:rights>
    <dc:relation>#{cgi_escape(metadata['relation'])}</dc:relation>
    <dc:identifier id="BookID" opf:scheme="UUID">#{uuid}</dc:identifier>\
#{cover_id_xml}
  </metadata>
EOF
      end

      def self.get_guide_xml(guide, file2id)
        guide_xml = "  <guide>\n"
        cover_page = guide['cover-page']
        if cover_page != nil
          if file2id[cover_page] == nil
            raise "Failed to find cover-page from manifest" 
          else
            guide_xml << "    <reference href=\"#{cover_page}\" " + 
              "type=\"cover\" title=\"Cover\"/>\n"
          end
        end
        toc_page =  guide['toc-page']
        if toc_page != nil
          if file2id[toc_page] == nil
            raise "Failed to find toc-page from manifest" 
          else
            guide_xml << "    <reference href=\"#{toc_page}\" type=\"toc\" " + 
              "title=\"Table of Contents\"/>\n"
          end
        end
        title_page =  guide['title-page']
        if title_page != nil
          if file2id[title_page] == nil
            raise "Failed to find title-page from manifest" 
          else
            guide_xml << "    <reference href=\"#{title_page}\" " + 
              "type=\"title-page\" title=\"Title Page\"/>\n"
          end
        end
        guide_xml << "  </guide>\n"
      end

      def self.get_spine_xml(spine, file2id)
        spine_xml = "  <spine toc=\"ncx\">\n"
        spine.each do |path|
          if file2id[path] != nil
            spine_xml << "    <itemref idref=\"#{file2id[path]}\"/>\n"
          else
            raise "Failed to find spine element `#{path}' from manifest"
          end
        end
        spine_xml << "  </spine>\n"
      end
    end
  end
end
