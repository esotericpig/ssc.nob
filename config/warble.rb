# encoding: UTF-8
# frozen_string_literal: true

# Generated using: mkdir config && warble config

# Disable Rake-environment-task framework detection by uncommenting/setting to false
# Warbler.framework_detection = false

Warbler::Config.new do |config|
  # Features: additional options controlling how the jar is built.
  # Currently the following features are supported:
  # - *gemjar*: package the gem repository in a jar file in WEB-INF/lib
  # - *executable*: embed a web server and make the war executable
  # - *runnable*: allows to run bin scripts e.g. `java -jar my.war -S rake -T`
  # - *compiled*: compile .rb files to .class files
  config.features = %w[gemjar runnable]

  # Application directories to be included in the app.
  # config.dirs = %w[ lib bin ]

  # Additional files/directories to include, above those in config.dirs
  # config.includes = FileList['lib/**/*.rb','bin/*']

  # Additional files/directories to exclude
  # config.excludes = FileList["lib/tasks/*"]

  # Additional Java .jar files to include.  Note that if .jar files are placed
  # in lib (and not otherwise excluded) then they need not be mentioned here.
  # JRuby and JRuby-Rack are pre-loaded in this list.  Be sure to include your
  # own versions if you directly set the value
  # config.java_libs += FileList["lib/java/*.jar"]

  # Loose Java classes and miscellaneous files to be included.
  # config.java_classes = FileList["target/classes/**.*"]

  # One or more pathmaps defining how the java classes should be copied into
  # the archive. The example pathmap below accompanies the java_classes
  # configuration above. See http://rake.rubyforge.org/classes/String.html#M000017
  # for details of how to specify a pathmap.
  # config.pathmaps.java_classes << "%{target/classes/,}p"

  # Bundler support is built-in. If Warbler finds a Gemfile in the
  # project directory, it will be used to collect the gems to bundle
  # in your application. If you wish to explicitly disable this
  # functionality, uncomment here.
  # config.bundler = false

  # An array of Bundler groups to avoid including in the war file.
  # Defaults to ["development", "test", "assets"].
  # config.bundle_without = []

  # Other gems to be included. If you don't use Bundler or a gemspec
  # file, you need to tell Warbler which gems your application needs
  # so that they can be packaged in the archive.
  # For Rails applications, the Rails gems are included by default
  # unless the vendor/rails directory is present.
  # config.gems += ["activerecord-jdbcmysql-adapter", "jruby-openssl"]
  # config.gems << "tzinfo"

  # Uncomment this if you don't want to package rails gem.
  # config.gems -= ["rails"]

  # The most recent versions of gems are used.
  # You can specify versions of gems by using a hash assignment:
  # config.gems["rails"] = "4.2.5"

  # You can also use regexps or Gem::Dependency objects for flexibility or
  # finer-grained control.
  # config.gems << /^sinatra-/
  # config.gems << Gem::Dependency.new("sinatra", "= 1.4.7")

  # Include gem dependencies not mentioned specifically. Default is
  # true, uncomment to turn off.
  # config.gem_dependencies = false

  # Array of regular expressions matching relative paths in gems to be
  # excluded from the war. Defaults to empty, but you can set it like
  # below, which excludes test files.
  # config.gem_excludes = [/^(test|spec)\//]

  # Pathmaps for controlling how application files are copied into the archive
  # config.pathmaps.application = ["WEB-INF/%p"]

  # Name of the archive (without the extension). Defaults to the basename
  # of the project directory.
  # config.jar_name = "myjar"

  # File extension for the archive. Defaults to either 'jar' or 'war'.
  config.jar_extension = 'jar'

  # Destination for the created archive. Defaults to project's root directory.
  config.autodeploy_dir = 'pkg/'

  # Name of the MANIFEST.MF template for the war file. Defaults to a simple
  # MANIFEST.MF that contains the version of Warbler used to create the war file.
  # config.manifest_file = "config/MANIFEST.MF"

  # When using the 'compiled' feature and specified, only these Ruby
  # files will be compiled. Default is to compile all \.rb files in
  # the application.
  # config.compiled_ruby_files = FileList['app/**/*.rb']

  # Determines if ruby files in supporting gems will be compiled.
  # Ignored unless compile feature is used.
  # config.compile_gems = false

  # When set it specify the bytecode version for compiled class files
  #
  # NOTE: This doesn't mean that this version of the JRE can run the Jar,
  #         as it also depends on the `jruby-jars` gem's version.
  #       See `Gemfile` for that version.
  config.bytecode_version = '1.8'

  # When set to true, Warbler will override the value of ENV['GEM_HOME'] even it
  # has already been set. When set to false it will use any existing value of
  # GEM_HOME if it is set.
  # config.override_gem_home = true

  # Allows for specifing custom executables
  # config.executable = ["rake", "bin/rake"]

  # Sets default (prefixed) parameters for the executables
  # config.executable_params = "do:something"
end
