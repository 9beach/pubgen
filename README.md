# Pubgen

Pubgen is a command-line based epub generator. Create an epub with YAML.

## Installation

```bash
$ # First, install Ruby and then
$ gem install pubgen
```

## Usage

```bash
$ pubgen -h
pubgen, an epub generator. (http://github.com/9beach/pubgen)

Usage:
  pubgen <yaml file> [-o <epub file>] [-v]
  pubgen <yaml file> -m

    -o, --output EPUB_PATH           Specify output epub file path
    -m, --meta-file-only             Generate .opf, .ncx, mimetype, ...
    -v, --verbose                    Verbose output
```

## Quick Start

### Create an epub
 
Prepare files (documents, images, style sheets, etc.) that make up the 
publication. Apple's iBooks requires strict xhtml. [`tidy -asxhtml`] 
(http://tidy.sourceforge.net/) will be helpful to you.

```bash
$ find .
.
./contents
./contents/a.html
./contents/b.html
./images
./images/1.jpg
./images/2.jpg
./images/3.jpg
./images/cover.jpg
./style.css
```

Create the utf-8 encoded YAML file describing the publication. As an example, 
`will_oldham.yml`.

```yaml
# METADATA: Publication metadata (title, author, publisher, etc.).
#
# See http://idpf.org/epub/20/spec/OPF_2.0.1_draft.htm#Section2.2
metadata:
  title: "Will Oldham: Wikipedia, the free encyclopedia"
  creator: Wikipedia
  date: 2012
  language: en
  subject: American alternative country singers
  publisher:
  contributor:
  description:
  source: "http://en.wikipedia.org/wiki/Will_Oldham"
  rights:
  relation:

# GUIDE: A set of references to fundamental structural features of the 
# publication, such as table of contents, foreword, bibliography, etc.
#
# See http://idpf.org/epub/20/spec/OPF_2.0.1_draft.htm#Section2.6
#
# If you provide cover-image without cover-page, pubgen automatically 
# generate cover-page xhtml, and add it to manifest and spine
guide:
  toc-page:
  title-page: 
  cover-page:
  cover-image: images/cover.jpg

# MANIFEST: A list of files (documents, images, style sheets, etc.) that make 
# up the publication.
#
# See http://idpf.org/epub/20/spec/OPF_2.0.1_draft.htm#Section2.3
#
# All the file paths in manifest ought to be relative to yaml's path and in the
# same or sub-directory of yaml. Say yaml's path is /book/a.yaml.
# - a/b/c.html                # good. in the sub-directory
# - d.jpg                     # good. in the same directory
# - ./e.jpg                   # good. in the same directory
# - /a/b/c.html               # bad. in the different directory
# - ../d.png                  # bad. in the parent directory
# - /book/e.html              # bad. although in the same directory
# - ../book/f.png             # bad. although in the same directory
manifest:
  - contents/a.html
  - contents/b.html
  - images/cover.jpg
  - images/1.jpg
  - images/2.jpg
  - images/3.jpg
  - style.css

# SPINE: An arrangement of documents providing a linear reading order.
#
# See http://idpf.org/epub/20/spec/OPF_2.0.1_draft.htm#Section2.4
spine:
  - contents/a.html
  - contents/b.html

# TOC: Table of contents
#
# See http://idpf.org/epub/20/spec/OPF_2.0.1_draft.htm#Section2.4.1
toc:
# Add a colon suffix to indent
  - 1 Music -- contents/a.html:
    - 1.1 Discography -- contents/a.html#discography: 
      - 1.1.1 Studio albums -- contents/a.html#studio_albums
    - 1.2 Response -- contents/a.html#response
  - 2 Film -- contents/b.html:
    - 2.1 Filmography -- contents/b.html#filmography
  - 3 Photography -- contents/b.html#photography
  - 4 References -- contents/b.html#references
  - 5 External links -- contents/b.html#external_links
```

Run pubgen.

```bash
$ pubgen /path/to/will_oldham.yml -v
mkdir .pubgen-4f4a210e
cp ./contents/a.html .pubgen-4f4a210e/contents
cp ./contents/b.html .pubgen-4f4a210e/contents
cp ./images/cover.jpg .pubgen-4f4a210e/images
cp ./images/1.jpg .pubgen-4f4a210e/images
cp ./images/2.jpg .pubgen-4f4a210e/images
cp ./images/3.jpg .pubgen-4f4a210e/images
cp ./style.css .pubgen-4f4a210e/.
cd .pubgen-4f4a210e
cat > META-INF/container.xml
cat > mimetype
cat > cover-pubgen.xhtml
cat > content.opf
cat > toc.ncx
zip > pubgen.epub
cd /path/to/prev_dir
mv .pubgen-4f4a210e/pubgen.epub 'Will Oldham_ Wikipedia, the free encyclopedia.epub'
rm -rf .pubgen-4f4a210e
# Successfully generated 'Will Oldham_ Wikipedia, the free encyclopedia.epub'
```

Done!

### Create meta files

If you understand [Open Packagin Format 2.0.1] 
(http://idpf.org/epub/20/spec/OPF_2.0.1_draft.htm) spec, and want to edit some 
properties of the epub before packaging, you can try pubgen with 
`--meta-file-only` option.

```bash
$ cd /path/to/epub_root
$ pubgen will_oldham.yml -m
cat > META-INF/container.xml
cat > mimetype
cat > cover-pubgen.xhtml
cat > content.opf
cat > toc.ncx
# edit content.opf/toc.ncx, and then
$ zip -r ../will_oldham.epub .
```

Done!
