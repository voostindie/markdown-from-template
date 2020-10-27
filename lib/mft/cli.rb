module MFT
  class Cli
    def run(templates_file, arguments = ARGV)
      unless File.exist?(templates_file)
        raise "Templates not found: #{templates_file}"
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

      templates = YAML.load_file(templates_file)

      if arguments[0] == '-l' || arguments[0] == '--list'
        puts templates.keys.sort.join("\n")
        exit
      end

      if arguments[0] == '-a' || arguments[0] == '--alfred'
        items = templates.keys.sort.map {|t|
          {
            :uid => t,
            :title => t,
            :arg => t
          }
        }
        puts JSON.dump({items: items})
        exit
      end


      template = templates[arguments[0]]
      if template.nil?
        raise "Template #{arguments[0]} not found in #{templates_file}. Pick one of " +
                templates.keys.join(', ')
      end

      puts Template.new(arguments[0], template).render
    end
  end
end