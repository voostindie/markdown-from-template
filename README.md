# MFT: Markdown from Template

## Introduction

This is a simple tool to create Markdown files at specific locations on your filesystem from [Liquid](https://shopify.github.io/liquid/) templates. This tool prompts you for each variable in the used template, creates a file and returns the path to the file just created.

(In hindsight I should probably have called this tool "TFT: Text from Template", because there's nothing special for Markdown in it. I might
just do that in the future.)

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

All templates are YAML files, one per template, in the directory `~/.mft`. 

See `sample.yaml` for an example template. Or read on.

Here's my template for creating a movie review:

```yaml
  variables:
    rating: 3
  suppress: [day, month, year]
  directory: '~/Notes/Personal/Movies'
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

The name of the template is the name of the file in the `~/.mft` directory, without the suffix. So, if we store the above template in the file `Movie.yaml`, the name of the template is `Movie`. This is the name you use from the command line.

### Variables

```yaml
variables:
  rating: 3
```

The `variables` section defines default values for each of the variables used in the Liquid templates. MFT will prompt you for each variable anyway (unless supressed, see below), but it will pre-fill the value if you specify a value. That makes for quick entry.

The variables `day`, `month` and `year` have automatic defaults, for today's date.

### PRO TIP: Setting values from scripts

If you really know what you're doing, you can set variable to the output of scripts. This offers a lot of flexibility, but also opens up Pandora's box, so be careful.

To run a script, simply set it as the value of a variable, surrounded with backticks:

```yaml
variables:
  rating: `echo $((1 + $RANDOM % 5))`
```

This will set the variable `rating` to, in this case, a random number from 1 to 5.

### Suppressing dialog boxes

In some cases you have variables with default values that you don't want to be reminded of, you can suppress them. In that case MFT won't prompt you for them and the default value will be used as is.

```yaml
suppress: day, month, year    
```

In this case I'm happy with the default date (today) and I don't want to be able to change them.

### Directory

```yaml
directory: '~/Notes/Personal/Movies'
```

This specifies in which directory the output of the template needs to be stored. This value is a template, so you can make the directory dynamic if you want.

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

This is the template for the file contents. It contains five variables: `title` and `rating`, `day`, `month` and `year`. The first one, `title` was already used in the filename. MFT will prompt you for it only once. The `rating` is used to generate a *starbar*. The last three variables were already mentioned: these get default values from the current date and prompting for them is suppressed.

### Putting it all together

Let's say I just watched [1917](https://www.imdb.com/title/tt8579674) and I want to write a short review of it.

I run `mft Movie`

MFT will prompt me for the title and the rating. I change the default rating from 3 to 4. 

This leaves me with a file `1917.md` with the following contents:

```md
# 1917

## Rating

★★★★☆ (4)

## Dates viewed

- 10-04-2020

#Movie
```

## Alfred workflow

I use [Alfred](https://www.alfredapp.com) extensively. So naturally I wrote a workflow for this tool. It's in the `alfred` subfolder and it's extremely simple: it lists the available templates and then fires off `mft` with the one you selected. If a file has been written, the workflow opens it in Obsidian for editing.

To install this in Alfred, this is what I do:

```sh
> cd ~/Library/Application\ Support/Alfred/Alfred.alfredpreferences/workflows
> ln -s /PATH/TO/MFT/alfred
```

To use a custom Ruby version, configure the workflow environment variable `RUBY_PATH` by pointing it to the directory Ruby is in. In my case, that's `/Users/vincent/.rbenv/shims`.

The editor is currently hardcoded to be Obsidian.