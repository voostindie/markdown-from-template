module MFT
  class Template
    def initialize(key, config)
      @name = key
      @templates = {
        directory: Liquid::Template.parse(config['directory']),
        filename: Liquid::Template.parse(config['filename']),
        contents: Liquid::Template.parse(config['contents'])
      }
      @defaults = config['defaults'] || {}
      @defaults['day'] = Date.today.day.to_s.rjust(2, '0')
      @defaults['month'] = Date.today.month.to_s.rjust(2, '0')
      @defaults['year'] = Date.today.year.to_s
      @variables = extract_variables(@templates.values)
    end

    def extract_variables(templates)
      templates.map do |template|
        template.root.nodelist
          .select { |n| n.is_a?(Liquid::Variable) }
          .select { |v| v.name.is_a?(Liquid::VariableLookup) }
          .map { |v| v.name.name }
      end.flatten.uniq
    end

    def render
      context = collect_values
      render_templates(context)
      write_output
    end

    private

    def collect_values
      context = {}
      @variables.each do |variable|
        command = "osascript -e 'display dialog \"Enter #{variable}\" " +
          "default answer \"#{@defaults[variable]}\" " +
          "with title \"New #{@name}\"'"
        output = `#{command}`
        if output =~ /^button returned:OK, text returned:(.*)$/
          context[variable] = $1.strip
        else
          raise 'Unexpected output or you cancelled, so we\'re stopping: ' + output
        end
      end
      context
    end

    def render_templates(context)
      @renders = {}
      @templates.each_pair do |sym, template|
        @renders[sym] = template.render(context)
        unless template.errors.empty?
          raise "Error while rendering template '#{sym}': #{template.errors}"
        end
      end
    end

    def write_output
      directory = sanitize_path(@renders[:directory])
      filename = Zaru.sanitize!(@renders[:filename])
      path = File.join(directory, filename)
      unless Dir.exist?(directory)
        raise "Directory doesn't exist: #{directory}"
      end
      if File.exist?(path) && File.size(path) > 0
        $stderr.puts "File already exists: #{filename}"
      else
        IO.write(path, @renders[:contents])
      end
      path
    end

    def sanitize_path(path)
      File.expand_path(path.split('/').map do |p|
        if p.empty?
          ''
        else
          Zaru.sanitize!(p)
        end
      end.join('/'))
    end
  end
end