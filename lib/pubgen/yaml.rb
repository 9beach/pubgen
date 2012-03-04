require 'rubygems'
require 'hpricot'
require 'cgi'

module Pubgen
  module YAML
    # Generates the YAML using input toc file.
    def self.generate(epub_root, toc_html)
      rpathmap = {}
      manifest = <<EOF
# METADATA: Publication metadata (title, author, publisher, etc.).
#
# See http://idpf.org/epub/20/spec/OPF_2.0.1_draft.htm#Section2.2
metadata:
  title:
  creator:
  date:
  language:
  subject:
  publisher:
  contributor:
  description:
  source:
  rights:
  relation:

# GUIDE: A set of references to fundamental structural features of the 
# publication, such as table of contents, foreword, bibliography, etc.
#
# See http://idpf.org/epub/20/spec/OPF_2.0.1_draft.htm#Section2.6
#
# If you provide cover-image without cover-page, pubgen automatically 
# generate cover-page xhtml, and add it to manifest and spine.
guide:
  toc-page: #{subpath2basepath(toc_html, epub_root)}
  title-page: 
  cover-page:
  cover-image:

# MANIFEST: A list of files (documents, images, style sheets, etc.) that make 
# up the publication.
#
# See http://idpf.org/epub/20/spec/OPF_2.0.1_draft.htm#Section2.3
manifest:
EOF
      Dir.glob(File.join(epub_root, '**/*')).each do |path|
        if File.directory?(path) == false
          next if /\.epub$/ =~ path.downcase
          rpath = subpath2basepath(path, epub_root)
          rpathmap[rpath] = true
          manifest << "  - #{rpath}\n"
        end
      end

      spine = <<EOF
# SPINE: An arrangement of documents providing a linear reading order.
#
# See http://idpf.org/epub/20/spec/OPF_2.0.1_draft.htm#Section2.4
spine:
EOF
      toc = <<EOF
# TOC: Table of contents
#
# See http://idpf.org/epub/20/spec/OPF_2.0.1_draft.htm#Section2.4.1
toc:
EOF
      doc = Hpricot(open(toc_html))
      spinemap = {}
      linkmap = {}
      doc.search("a[@href]").each do |a| 
        href = a['href']
        if href[0] == '#' # index.html's anchor
          href = File.basename(toc_html) + href
        end
        path, anchor = href.split("#")

        # href is relative to index.html, so we need to change it relative to
        # epub_root
        abspath = File.absolute_path(File.join(File.dirname(toc_html), path))
        rpath = subpath2basepath(abspath, epub_root)
        next if rpath == nil
        # toc paths should be sub-set of manifest
        next if rpathmap[rpath] == nil

        text = CGI.unescape(a.inner_text).gsub(/[\n\r]/, ' ').gsub(/  /, ' ')
        next if text == ''

        # proper toc element
        link = rpath + (anchor ? '#' + anchor : '')
        next if linkmap[link] == true
        linkmap[link] = true
        if text.include?(':')
          toc << "  - \"#{text} -- #{link}\"\n"
        else
          toc << "  - #{text} -- #{link}\n"
        end
        # add it to spine map
        spinemap[rpath] = true
      end
      spinemap.each do |k, v|
        rpathmap.delete(k)
        spine << "  - #{k}\n"
      end
      # check spine
      spine_comment = false
      rpathmap.each do |k, v|
        if /.*\.x?html?$/ =~ k
          if spine_comment == false
            spine_comment = true
            spine << "# You need to reorder below elements. They are not " << 
                     "in TOC but in manifest.\n"
          end
          spine << "  - #{k}\n"
        end
      end

      return "#{manifest}\n#{spine}\n#{toc}"
    end

    # Returns the relative path of input path to base_pase. It's private.
    def self.subpath2basepath(path, base_path)
      if File.absolute_path(path).include?(File.absolute_path(base_path))
        return File.absolute_path(path)[
          File.absolute_path(base_path).size + 1..-1]
      else
        return nil
      end
    end
  end
end
