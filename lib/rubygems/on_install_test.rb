Gem.autoload(:Uninstaller, 'rubygems/uninstaller')
Gem::Commands.autoload(:TestCommand, 'rubygems/commands/test_command')
Gem.autoload(:RakeNotFoundError, 'exceptions')
Gem.autoload(:TestError, 'exceptions')

Gem.post_build do |gem|
  options = Gem.configuration["test_options"] || { }

  if options["auto_test_on_install"] or options["test_on_install"]
    if options["auto_test_on_install"] or
        gem.ui.ask_yes_no("Test #{gem.spec.name} (#{gem.spec.version})?", true)

      begin
        Gem::Commands::TestCommand.new(gem.spec, true).execute
      rescue Gem::RakeNotFoundError, Gem::TestError
        if (options.has_key?("force_install") and !options["force_install"]) or
            options["force_uninstall_on_failure"] or
            gem.ui.ask_yes_no("Testing #{gem.spec.name} (#{gem.spec.version}) failed. Uninstall?", false)

            false
        end
      end
    end
  end
end
