require 'test/unit'
require 'yaml'

require 'helper'

$test_yaml = <<EOF
metadata:
  title: "Will Oldham"
  creator: Wikipedia
  date: 2012
  language: en
  subject: American alternative country singers
  publisher: 9beach
  contributor: 9valley
  description: describe here
  source: "http://en.wikipedia.org/wiki/Will_Oldham"
  rights: I've got no right
  relation: bad relation

guide:
  toc-page: contents/a.html
  title-page: contents/b.html
  cover-page: contents/c.html
  cover-image: images/cover.jpg

manifest:
  - contents/a.html
  - contents/b.html
  - contents/c.html
  - images/cover.jpg
  - images/1.jpg
  - images/2.jpg
  - images/3.jpg
  - style.css

spine:
  - contents/a.html
  - contents/b.html
  - contents/c.html

toc:
  - 1 Music -- contents/a.html:
    - 1.1 Discography -- contents/a.html#discography: 
      - 1.1.1 Studio albums -- contents/a.html#studio_albums
    - 1.2 Response -- contents/a.html#response
  - 2 Film -- contents/b.html:
    - 2.1 Filmography -- contents/b.html#filmography
  - 3 Photography -- contents/b.html#photography
  - 4 References -- contents/b.html#references
  - 5 External links -- contents/c.html
EOF

class TestOPF < Test::Unit::TestCase
  def setup
    $yaml = YAML::load $test_yaml
  end

  def test_metadata
    xml = Pubgen::OPF.generate($yaml, 'aaaaaaaa-1111')
    assert_match(/<dc:title>Will Oldham<\/dc:[^>].*>/, xml)
    assert_match(/<dc:creator opf:role="aut">Wikipedia<\/dc:[^>].*>/, xml)
    assert_match(/<dc:date>2012<\/dc:[^>].*>/, xml)
    assert_match(/<dc:language>en<\/dc:[^>].*>/, xml)
    assert_match(/<dc:subject>American alternative country singers<\/dc:[^>].*>/, xml)
    assert_match(/<dc:publisher>9beach<\/dc:[^>].*>/, xml)
    assert_match(/<dc:description>describe here<\/dc:[^>].*>/, xml)
    assert_match(/<dc:source>http:\/\/en.wikipedia.org\/wiki\/Will_Oldham<\/dc:[^>].*>/, xml)
    assert_match(/<dc:rights>I've got no right<\/dc:[^>].*>/, xml)
    assert_match(/<dc:relation>bad relation<\/dc:[^>].*>/, xml)
    assert_match(/<dc:contributor opf:role="bkp">9valley<\/dc:[^>].*>/, xml)
    assert_match(/<dc:identifier id="BookID" opf:scheme="UUID">aaaaaaaa-1111<\/dc:[^>].*>/, xml)
  end

  def test_guide
    xml = Pubgen::OPF.generate($yaml, 'aaaaaaaa')

    assert_match(/reference href="contents\/a.html" type="toc"/, xml)
    assert_match(/reference href="contents\/b.html" type="title-page"/, xml)
    assert_match(/reference href="contents\/c.html" type="cover"/, xml)
    assert_match(/<meta name="cover" content/, xml)

    $yaml['guide']['cover-image'] = nil
    xml = Pubgen::OPF.generate($yaml, 'aaaaaaa')
    assert_no_match(/<meta name="cover" content/, xml)
  end

  def test_manifest
    xml = Pubgen::OPF.generate($yaml, 'a')
    assert_match(/item id="i001" href="contents\/a.html" media-type="application\/xhtml\+xml"\/>/, xml)
    assert_match(/item id="i002" href="contents\/b.html" media-type="application\/xhtml\+xml"\/>/, xml)
    assert_match(/item id="i003" href="contents\/c.html" media-type="application\/xhtml\+xml"\/>/, xml)
    assert_match(/item id="i004" href="images\/cover.jpg" media-type="image\/jpeg"\/>/, xml)
    assert_match(/item id="i005" href="images\/1.jpg" media-type="image\/jpeg"\/>/, xml)
    assert_match(/item id="i006" href="images\/2.jpg" media-type="image\/jpeg"\/>/, xml)
    assert_match(/item id="i007" href="images\/3.jpg" media-type="image\/jpeg"\/>/, xml)
    assert_match(/item id="i008" href="style.css" media-type="text\/css"\/>/, xml)
    assert_match(/item id="ncx" href="#{Pubgen::OPF.ncx_path}" media-type="application\/x-dtbncx\+xml"\/>/, xml)
  end

  def test_spine
    xml = Pubgen::OPF.generate($yaml, 'aaaaaaaa-1111')
    assert_match(/<itemref idref="i001"\/>/, xml)
    assert_match(/<itemref idref="i002"\/>/, xml)
    assert_match(/<itemref idref="i003"\/>/, xml)
    assert_no_match(/<itemref idref="i004"\/>/, xml)
    assert_no_match(/<itemref idref="i005"\/>/, xml)
    assert_no_match(/<itemref idref="i006"\/>/, xml)
    assert_no_match(/<itemref idref="i007"\/>/, xml)
    assert_no_match(/<itemref idref="i008"\/>/, xml)
    assert_no_match(/<itemref idref="ncx"\/>/, xml)
  end
end
