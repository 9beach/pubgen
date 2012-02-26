# Pubgen

Pubgen is a simple command-line based epub generator. With the simple YAML 
file, Pubgen generate the epub file for you. 

## Installation

```bash
$ # First, install Ruby and then
$ gem install pubgen
```

## Usage

```bash
$ pubgen -h
pubgen 0.1.0, a epub generator.

Usage:
  pubgen <yaml file> [-o <epub file>] [-v]
  pubgen <yaml file> -m

    -o, --output EPUB_PATH           Specify output epub file path
    -m, --meta-file-only             Generate .opf, .ncx, mimetype, ...
    -v, --verbose                    Verbose output
```

## Quick Start
 
Prepare files (documents, images, style sheets, etc.) that make up the 
publication. iBooks requires strict xhtml format, 
[`tidy -asxhtml`] (http://tidy.sourceforge.net/) will be helpful.

```bash
$ find .
.
./contents
./contents/a-1.html
./contents/a-2.html
./contents/a.html
./contents/b.html
./images
./images/1.jpg
./images/2.jpg
./images/3.jpg
./images/cover.jpg
./style.css
```
Create the YAML file describing your publication. As a example, 
`will_oldham.yml`.

```yaml
# METADATA: Publication metadata (title, author, publisher, etc.).
#
# See http://idpf.org/epub/20/spec/OPF_2.0.1_draft.htm#Section2.2
# -*- encoding: utf-8 -*-
metadata:
  title: "Will Oldham: Wikipedia, the free encyclopedia"
  creator: Wikipedia
  date: 2012
  language: en
  subject: American alternative country singers
  publisher:
  contrubuter:
  description:
  source: "http://en.wikipedia.org/wiki/Will_Oldham"
  rights:
  relation:

# GUIDE: A set of references to fundamental structural features of the 
# publication, such as table of contents, foreword, bibliography, etc.
#
# See http://idpf.org/epub/20/spec/OPF_2.0.1_draft.htm#Section2.6
guide:
  toc-page:
  title-page: 
# If you provide cover-image without cover-page, pubgen automatically 
# generate cover-page xhtml, and add it to manifest and spine
  cover-image: images/cover.jpg
  cover-page:

# MANIFEST: A list of files (documents, images, style sheets, etc.) that make 
# up the publication.
#
# All the files in manifest ought to be in the same or sub-directory of yaml.
# Say yaml's path is /book/a.yaml.
# - a/b/c.html                # good. in the sub-directory
# - d.jpg                     # good. in the same directory
# - ./e.jpg                   # good. in the same directory
# - /a/b/c.html               # bad. in the different directory
# - ../d.png                  # bad. in the parent directory
# - /book/e.html              # bad. although in the same directory
# - ../book/f.png             # bad. although in the same directory
manifest:
  - contents/a.html
  - contents/a-1.html
  - contents/a-2.html
  - contents/b.html
  - images/cover.jpg
  - images/1.jpg
  - images/2.jpg
  - images/3.jpg
  - style.css

# SPINE: An arrangement of documents providing a linear reading order.
spine:
  - contents/a.html
  - contents/a-1.html
  - contents/a-2.html
  - contents/b.html

# TOC: Table of contents
toc:
  - Music -- contents/a.html:   # don't forget colon to indent
    - Discography -- contents/a-1.html
    - Response -- contents/a-2.html
  - Film -- contents/b.html
```

Run pubgen.

```bash
$ pubgen /path/to/will_oldham.yml -v
mkdir .pubgen-4f4a210e
cp ./contents/a.html .pubgen-4f4a210e/contents
cp ./contents/a-1.html .pubgen-4f4a210e/contents
cp ./contents/a-2.html .pubgen-4f4a210e/contents
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
cd /path/to/pwd
mv .pubgen-4f4a210e /pubgen.epub 'Will Oldham_ Wikipedia, the free encyclopedia.epub'
rm -rf .pubgen-4f4a210e
# Successfully generated 'Will Oldham_ Wikipedia, the free encyclopedia.epub'
```
