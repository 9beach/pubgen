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

class TestNCX < Test::Unit::TestCase
  def setup
    $yaml = YAML::load $test_yaml
  end

  def test_generate
    xml = Pubgen::NCX.generate('English Patient', $yaml['toc'], '1111')

    assert_match(/<meta content="1111" name="dtb:uid"\/>/, xml)
    assert_match(/^    <navPoint id="d001" playOrder="1">/, xml)
    assert_match(/^      <content src="contents\/a.html"/, xml)
    assert_match(/^        <text>1 Music</, xml)
    assert_match(/^      <navPoint id="d002" playOrder="2">/, xml)
    assert_match(/^        <content src="contents\/a.html#discography"/, xml)
    assert_match(/^          <text>1.1 Discography</, xml)
    assert_match(/^        <navPoint id="d003" playOrder="3">/, xml)
    assert_match(/^          <content src="contents\/a.html#studio_albums"/, xml)
    assert_match(/^            <text>1.1.1 Studio albums</, xml)
    assert_match(/^      <navPoint id="d004" playOrder="4">/, xml)
    assert_match(/^        <content src="contents\/a.html#response"/, xml)
    assert_match(/^          <text>1.2 Response</, xml)
    assert_match(/^    <navPoint id="d005" playOrder="5">/, xml)
    assert_match(/^      <content src="contents\/b.html"/, xml)
    assert_match(/^        <text>2 Film</, xml)
    assert_match(/^      <navPoint id="d006" playOrder="6">/, xml)
    assert_match(/^        <content src="contents\/b.html#filmography"/, xml)
    assert_match(/^          <text>2.1 Filmography</, xml)
    assert_match(/^    <navPoint id="d007" playOrder="7">/, xml)
    assert_match(/^      <content src="contents\/b.html#photography"/, xml)
    assert_match(/^        <text>3 Photography</, xml)
    assert_match(/^    <navPoint id="d008" playOrder="8">/, xml)
    assert_match(/^      <content src="contents\/b.html#references"/, xml)
    assert_match(/^        <text>4 References</, xml)
    assert_match(/^    <navPoint id="d009" playOrder="9">/, xml)
    assert_match(/^      <content src="contents\/c.html"/, xml)
    assert_match(/^        <text>5 External links</, xml)
  end
end
