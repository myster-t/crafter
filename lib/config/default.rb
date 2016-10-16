load "#{Crafter::ROOT}/config/default_scripts.rb"

# All your configuration should happen inside configure block
Crafter.configure do

  # This are projects wide instructions
  add_platform({:platform => :ios, :deployment => 8.0})
  add_git_ignore
  duplicate_configurations(
    {
      :dev_release => :release, 
      :qa_debug => :debug,
      :qa => :release,
      :uat => :release,
    }
  )

  # set of options, warnings, static analyser and anything else normal xcode treats as build options
  set_options %w(
    RUN_CLANG_STATIC_ANALYZER
    GCC_TREAT_WARNINGS_AS_ERRORS
  )

  set_build_settings({
    :'WARNING_CFLAGS' => %w(
    -Weverything
    -Wno-objc-missing-property-synthesis
    -Wno-unused-macros
    -Wno-disabled-macro-expansion
    -Wno-gnu-statement-expression
    -Wno-language-extension-token
    -Wno-overriding-method-mismatch
    ).join(" ")
  })

  set_build_settings({
    :'BUNDLE_ID_SUFFIX' => '.dev',
    :'BUNDLE_DISPLAY_NAME_SUFFIX' => 'dev',
    :'KZBEnv' => 'DEV'
  }, configuration: :debug)

  set_build_settings({
    :'BUNDLE_ID_SUFFIX' => '.dev',
    :'BUNDLE_DISPLAY_NAME_SUFFIX' => 'dev',
    :'KZBEnv' => 'DEV'
  }, configuration: :dev_release)

  set_build_settings({
    :'BUNDLE_ID_SUFFIX' => '.qa',
    :'BUNDLE_DISPLAY_NAME_SUFFIX' => 'qa',
    :'KZBEnv' => 'QA'
  }, configuration: :qa_debug)

  set_build_settings({
    :'BUNDLE_ID_SUFFIX' => '.qa',
    :'BUNDLE_DISPLAY_NAME_SUFFIX' => 'qa',
    :'KZBEnv' => 'QA'
  }, configuration: :qa)

  set_build_settings({
    :'BUNDLE_ID_SUFFIX' => '.uat',
    :'BUNDLE_DISPLAY_NAME_SUFFIX' => 'uat',
    :'KZBEnv' => 'UAT'
  }, configuration: :uat)

  set_build_settings({
    :'BUNDLE_ID_SUFFIX' => '',
    :'BUNDLE_DISPLAY_NAME_SUFFIX' => '',
    :'KZBEnv' => 'PRODUCTION'
  }, configuration: :release)

  # CUSTOM: Modify plist file to include suffix and displayname
  # CUSTOM: Add empty KZBootstrapUserMacros.h file to your project and .gitignore
  # CUSTOM: Add KZBEnvironments.plist with list of your environments under KZBEnvironments key

  # target specific options, :default is just a name for you, feel free to call it whatever you like
  with :default do

    # each target have set of pods
    pods << %w(KZAsserts KZBootstrap KZBootstrap/Logging KZBootstrap/Debug)

    # each target can have optional blocks, eg. crafter will ask you if you want to include networking with a project
    add_option :afnetworking do
      pods << 'AFNetworking'
    end

    add_option :magicalrecord do
      pods << 'MagicalRecord'
    end

    add_option :cocoalumberjack do
      pods << 'CocoaLumberjack'
    end

    add_option :fabric do
      pods << 'Fabric'
      pods << 'Crashlytics'
    end

    # each target can have shell scripts added, in this example we are adding my icon versioning script as in http://www.merowing.info/2013/03/overlaying-application-version-on-top-of-your-icon/
    # scripts << {:name => 'icon versioning', :script => Crafter.icon_versioning_script}

    # we can also execute arbitrary ruby code when configuring our projects, here we rename all our standard icon* to icon_base for versioning script
    # icon_rename = proc do |file|
    #   extension = File.extname(file)
    #   file_name = File.basename(file, extension)
    #   File.rename(file, "#{File.dirname(file)}/#{file_name}_base#{extension}")
    # end

    # Dir['**/Icon.png'].each(&icon_rename)
    # Dir['**/Icon@2x.png'].each(&icon_rename)
    # Dir['**/Icon-72.png'].each(&icon_rename)
    # Dir['**/Icon-72@2x.png'].each(&icon_rename)

    # add build script for bootstrap
    scripts << {:name => 'KZBootstrap setup', :script => '"${SRCROOT}/Pods/KZBootstrap/Pod/Assets/Scripts/bootstrap.sh"'}

  end

  # more targets setup
  with :tests do
    add_option :kiwi do
      pods << 'Kiwi'
      scripts << {:name => 'command line unit tests', :script => Crafter.command_line_test_script}
    end
  end
end
