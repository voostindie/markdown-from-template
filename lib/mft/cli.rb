module MFT
  class Cli
    def run(templates_dir, arguments = ARGV)
      unless Dir.exist?(templates_dir)
        raise "Templates not found: #{templates_dir}"
      end

      if arguments.size != 1
        puts 'Usage: mft [-l|--list] [-a|--alfred] <template>'
        puts
        puts 'Where <template> is the name of the template to use.'
        puts 'Run mft -l or mft --list to get a list of available templates.'
        puts 'Run mft -a or mft --alfred to get the list of available templates in Alfred JSON format.'
        puts
        exit
      end

      if arguments[0] == '-l' || arguments[0] == '--list'
        templates = load_templates(templates_dir)
        puts templates.join("\n")
        exit
      end

      if arguments[0] == '-a' || arguments[0] == '--alfred'
        templates = load_templates(templates_dir)
        items = templates.map {|t|
          {
            :uid => t,
            :title => t,
            :arg => t
          }
        }
        puts JSON.dump({items: items})
        exit
      end

      template_file = File.join(templates_dir, "#{arguments[0]}.yaml")
      unless File.exist?(template_file)
        raise "Template #{arguments[0]} not found in #{templates_dir}. Pick one of " +
                templates.join(', ')
      end

      template = YAML.load_file(template_file)
      puts Template.new(arguments[0], template).render
    end

    private

    def load_templates(templates_dir)
      Dir.children(templates_dir)
         .select { |f| f.end_with?('.yaml') && File.file?(File.join(templates_dir, f)) }
         .map { |f| File.basename(f, '.yaml') }
         .sort
    end
  end
end