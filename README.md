# MFT: Markdown from Template

## Introduction

This is a simple tool to create Markdown files at specific locations on your filesystem from [Liquid ](https://shopify.github.io/liquid/)templates. This tool prompts you for each variable in the used template, creates a file and opens it in your default Markdown editor.

## Prerequisites

A working Mac running an actual version of macOS.

## Installation

```sh
> git clone https://github.com/voostindie/markdown-from-template.git
> cd markdown-from-template
> bundle install
```

## Usage

```sh
> mft <template>
```

This runs MFT against the specified template. This assumes you have added the `exe` directory to your PATH.

To see the list of available templates run `mft -l` or `mft --list`. 

If you want the list in Alfred's JSON format instead, run `mft -a` or `mft --alfred`. This options exists only for the accompanying Alfred workflow (see below).

## Creating templates

All templates are in a single YAML file, called `templates.yaml` in the root of this tool. When you clone the repository there's nothing there, so the tool won't work. You have to create this file first.

See `sample.yaml` for an example. Or read on.

Here's my template for creating a movie review:

```yaml
movie:
  defaults:
    rating: 3
  directory: '~/Library/Mobile Documents/27N4MQEA55~pro~writer/Documents/Movies'
  filename: '{{title}}.md'
  contents: |
    # {{title}}

    ## Rating

    {% capture left -%}{{ rating }}{%- endcapture -%}
    {%- capture right -%}{{ 5 | minus: left }}{%- endcapture -%}
    {{"★★★★★" | truncate: left, ""}}{{"☆☆☆☆☆" | truncate: right, "" }} ({{rating}})

    ## Dates viewed

    - {{day}}-{{month}}-{{year}}

    #Movie
```

Let's break this down.

### Template name

```yaml
movie:
```

This is the name of the template. Every template has a unique name. This is the name you use from the command line.

### Default values

```yaml
defaults:
  rating: 3
```

The `defaults` section defines default values for each of the variables used in the Liquid templates. MFT will prompt you for each variable anyway, but it will pre-fill the value if you specify a default. That makes for quick entry.

The variables `day`, `month` and `year` have automatic defaults, for today's date.

### Directory

```yaml
directory: '~/Library/Mobile Documents/27N4MQEA55~pro~writer/Documents/Movies'
```

This specifies in which directory the output of the template needs to be stored. This value is a template, so you can make the directory dynamic if you want.

In my case, this points to a subdirectory in [iA Writer](https://ia.net/writer)'s  iCloud directory.

### Filename

```yaml
filename: '{{title}}.md'
```

This specifies the name of the file that's to be created. The value is a template. This one uses the variable `{{title}}`, which MFT will trigger me for when I run it.

Note that the filename is sanitized, replacing all characters that are not valid in filenames. So, you can type anything you want here. The same applies to the directory template by the way.

### Contents

```yaml
  contents: |
    # {{title}}

    ## Rating

    {% capture left -%}{{ rating }}{%- endcapture -%}
    {%- capture right -%}{{ 5 | minus: left }}{%- endcapture -%}
    {{"★★★★★" | truncate: left, ""}}{{"☆☆☆☆☆" | truncate: right, "" }} ({{rating}})

    ## Dates viewed

    - {{day}}-{{month}}-{{year}}

    #Movie
```

This is the template for the file contents. It contains five variables: `title` and `rating`, `day`, `month` and `year`. The first one, `title` was already used in the filename. MFT will prompt you for it only once. The `rating` is used to generate a *starbar*. The last three variables were already mentioned: these get default values from the current date.

### Putting it all together

Let's say I watched [1917](https://www.imdb.com/title/tt8579674) yesterday, and I want to write a short review of it.

I run `mft movie`

MFT will prompt me for the title, rating, day, month and year. All except the title have default values. I change the rating from 3 to 4 and the day from today to yesterday. 

This leaves me with a file `1917.md` opened in iA Writer (my default Markdown editor), with the following contents:

```md
# 1917

## Rating

★★★★☆ (4)

## Dates viewed

- 10-04-2020

#Movie
```

## Alfred workflow

I use [Alfred](https://www.alfredapp.com) extensively. So naturally I wrote a workflow for this tool. It's in the `alfred` subfolder and it's extremely simple: it lists the available templates and then fires off `mft` with the one you selected.

To install this in Alfred, this is what I do:

```sh
> cd ~/Library/Application\ Support/Alfred/Alfred.alfredpreferences/workflows
> ln -s /PATH/TO/MFT/alfred
```

To use a custom Ruby version, configure the workflow environment variable `RUBY_PATH` by pointing it to the directory Ruby is in. In my case, that's `/Users/vincent/.rbenv/shims`.