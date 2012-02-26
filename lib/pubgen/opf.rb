require 'cgi'

module Pubgen
  module OPF
    def self.ncx_path
      NCX_PATH
    end

    def self.generate(yaml, uuid)
      cover_id, manifest_xml, file2id = 
            OPFImpl.get_cover_id_and_manifest_xml(yaml['guide']['cover-image'], 
                                                  yaml['manifest'])
      metadata_xml = OPFImpl.get_metadata_xml(yaml['metadata'], uuid, cover_id)
      spine_xml = OPFImpl.get_spine_xml(yaml['spine'], file2id)
      guide_xml = OPFImpl.get_guide_xml(yaml['guide'], file2id)
      return OPF_XML_HEADER + metadata_xml + manifest_xml + spine_xml + 
            guide_xml + OPF_XML_FOOTER
    end

    def self.valid_manifest_element?(e)
      e[0..2] != "../" && e[0] != "/"
    end

    # define OPFImpl class and some constants
    # they are all private, only Pubgen.OPF.generate use them
    NCX_PATH = "toc.ncx"
    METADATA_FORMAT = <<EOF
  <metadata xmlns:dc="http://purl.org/dc/elements/1.1/" xmlns:opf="http://www.idpf.org/2007/opf">
    <dc:title>%s</dc:title>
    <dc:creator opf:role="aut">%s</dc:creator>
    <dc:date>%s</dc:date>
    <dc:language>%s</dc:language>
    <dc:subject>%s</dc:subject>
    <dc:publisher>%s</dc:publisher>
    <dc:description>%s</dc:description>
    <dc:contributor opf:role="bkp">%s</dc:contributor>
    <dc:source>%s</dc:source>
    <dc:rights>%s</dc:rights>
    <dc:relation>%s</dc:relation>
    <dc:identifier id="BookID" opf:scheme="UUID">%s</dc:identifier>%s
  </metadata>
EOF
    OPF_XML_HEADER = <<EOF
<?xml version='1.0' encoding='utf-8'?>
<package xmlns="http://www.idpf.org/2007/opf" version="2.0" unique-identifier="uuid_id">
EOF
    OPF_XML_FOOTER = '</package>'

    module OPFImpl
      def self.guess_media_type(filename)
        case filename.downcase
        when /.*\.x?html?$/i
          'application/xhtml+xml'
        when /.*\.css$/i
          'text/css'
        when /.*\.(jpeg|jpg)$/
          'image/jpeg'
        when /.*\.png$/i
          'image/png'
        when /.*\.gif$/i
          'image/gif'
        when /.*\.svg$/i
          'image/svg+xml'
        when /.*\.ncx$/i
          'application/x-dtbncx+xml'
        when /.*\.opf$/i
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
            raise "One of manifest element (" + path + ") is not in sub-directory of yaml file"
          end
          id = "i%03d" % no
          manifest_xml += "    <item id=\"#{id}\" href=\"#{path}\" media-type=\"#{guess_media_type(path)}\"/>\n"
          if path == cover_path
            cover_id = id
          end
          file2id[path] = id

          no += 1
        end

        if cover_path && cover_id == nil
          raise "Can't find cover-image from manifest" 
        end

        manifest_xml += "    <item id=\"ncx\" href=\"#{NCX_PATH}\" media-type=\"application/x-dtbncx+xml\"/>\n  </manifest>\n"

        return cover_id, manifest_xml, file2id
      end

      def self.get_metadata_xml(metadata, uuid, cover_id)
        cover_id_xml = ''
        if cover_id != nil
          cover_id_xml = "\n    <meta name=\"cover\" content=\"%s\"/>" % cover_id
        end
        METADATA_FORMAT % [
          CGI.escapeHTML(metadata['title'] || ''),
          CGI.escapeHTML(metadata['creator'] || ''), 
          CGI.escapeHTML((metadata['date'].is_a?(Fixnum) ? 
                          metadata['date'].to_s : metadata['date']) || ''), 
          CGI.escapeHTML(metadata['language'] || ''), 
          CGI.escapeHTML(metadata['subject'] || ''), 
          CGI.escapeHTML(metadata['publisher'] || ''), 
          CGI.escapeHTML(metadata['description'] || ''), 
          CGI.escapeHTML(metadata['contributor'] || ''), 
          CGI.escapeHTML(metadata['source'] || ''), 
          CGI.escapeHTML(metadata['rights'] || ''), 
          CGI.escapeHTML(metadata['relation'] || ''), 
          uuid, cover_id_xml
        ]
      end

      def self.get_guide_xml(guide, file2id)
        guide_xml = "  <guide>\n"
        cover_page = guide['cover-page']
        if cover_page != nil
          if file2id[cover_page] == nil
            raise "Can't find cover-page from manifest" 
          else
            guide_xml += "    <reference href=\"%s\" type=\"cover\" title=\"Cover\"/>\n" % cover_page
          end
        end
        toc_page =  guide['toc-page']
        if toc_page != nil
          if file2id[toc_page] == nil
            raise "Can't find toc-page from manifest" 
          else
            guide_xml += "    <reference href=\"%s\" type=\"toc\" title=\"Table of Contents\"/>\n" % toc_page
          end
        end
        title_page =  guide['title-page']
        if title_page != nil
          if file2id[title_page] == nil
            raise "Can't find title-page from manifest" 
          else
            guide_xml += "    <reference href=\"%s\" type=\"title-page\" title=\"Title Page\"/>\n" % toc_page
          end
        end
        guide_xml += "  </guide>\n"
      end

      def self.get_spine_xml(spine, file2id)
        spine_xml = "  <spine toc=\"ncx\">\n"
        spine.each do |path|
          if file2id[path] != nil
            spine_xml += "    <itemref idref=\"#{file2id[path]}\"/>\n"
          else
            raise "Can't find spine element `#{path}' from manifest"
          end
        end
        spine_xml += "  </spine>\n"
      end
    end
  end
end
