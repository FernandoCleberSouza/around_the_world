AROUND_ROOT        = ENV["AROUND_ROOT"] || File.join(File.dirname(File.expand_path(__FILE__)))
AROUND_MRUBY_ROOT  = File.join(AROUND_ROOT, "mruby")
AROUND_GEMBOX_ROOT = File.join(AROUND_ROOT, "mrbgems")

MRuby::Toolchain.new(:gcc_gertec) do |conf|
	CYGWIN_ROOT = File.join(File.dirname(File.expand_path(__FILE__)), "..", "..", "..")
	SDK_BIN_PATH = File.join(CYGWIN_ROOT, "opt", "gnueabi", "bin")
	SDK_INCLUDE_PATH = [File.join(root, "include"), File.join(CYGWIN_ROOT, "opt", "gedi_v00_008_0004", "include"), File.join(CYGWIN_ROOT, "opt", "gnueabi", "arm-brcm-linux-gnueabi", "include")]
	SDK_LIBRARY_PATH = [File.join(CYGWIN_ROOT, "opt", "gnueabi", "arm-brcm-linux-gnueabi", "sysroot", "lib"), File.join(CYGWIN_ROOT, "opt", "gnueabi", "arm-brcm-linux-gnueabi", "sysroot", "usr", "lib"), File.join(CYGWIN_ROOT, "opt", "gedi_v00_008_0004", "lib")]
	
  [conf.cc, conf.objc, conf.asm].each do |cc|
    cc.command = File.join(SDK_BIN_PATH, "arm-brcm-linux-gnueabi-gcc")
    cc.flags = %w(-g -std=gnu99 -O3 -Wall -Werror-implicit-function-declaration -Wdeclaration-after-statement)
    cc.option_include_path = '-I%s'
	cc.include_paths = SDK_INCLUDE_PATH
    cc.option_define = '-D%s'
    cc.compile_options = '%{flags} -MMD -o %{outfile} -c %{infile}'
  end

  [conf.cxx].each do |cxx|
    cxx.command = '/cygdrive/c/Cloudwalk/cygwin64/opt/gnueabi/bin/arm-brcm-linux-gnueabi-g++'
    cxx.flags = %w(-g -O3 -Wall -Werror-implicit-function-declaration)
	cxx.include_paths += SDK_INCLUDE_PATH
	cxx.option_include_path = '-I%s'
    cxx.option_define = '-D%s'
    cxx.compile_options = '%{flags} -MMD -o %{outfile} -c %{infile}'
  end

  conf.linker do |linker|
    #linker.command = '/cygdrive/c/Cloudwalk/cygwin64/opt/gnueabi/bin/arm-brcm-linux-gnueabi-gcc'
	linker.command = File.join(SDK_BIN_PATH, "arm-brcm-linux-gnueabi-gcc")
    linker.flags = %w(-Wl --whole-archive -lgedi --no-whole-archive)
    linker.libraries = %w(m)
	linker.library_paths += SDK_LIBRARY_PATH
    linker.option_library = '-l%s'
    linker.option_library_path = '-L%s'
    linker.link_options = '%{flags} -o %{outfile} %{objs} %{flags_before_libraries} %{libs} %{flags_after_libraries}'
  end

  conf.exts do |exts|
	exts.object = '.o'
	exts.executable = '.out'
	exts.library = '.a'
  end

  # file separetor
  conf.file_separator = '/'
end

MRuby::Build.new do |conf|
  toolchain :gcc

  enable_debug

  # Use mrbgems
  # conf.gem 'examples/mrbgems/ruby_extension_example'
  # conf.gem 'examples/mrbgems/c_extension_example' do |g|
  #   g.cc.flags << '-g' # append cflags in this gem
  # end
  # conf.gem 'examples/mrbgems/c_and_ruby_extension_example'
  # conf.gem :github => 'masuidrive/mrbgems-example', :branch => 'master'
  # conf.gem :git => 'git@github.com:masuidrive/mrbgems-example.git', :branch => 'master', :options => '-v'

  # include the default GEMs
  #conf.gembox 'default'
  #conf.gembox File.join(AROUND_ROOT, "mrbgems", "around")
  conf.cc.defines << %w(DISABLE_GEMS SHA256_DIGEST_LENGTH=32 SHA512_DIGEST_LENGTH=64 MRB_STACK_EXTEND_DOUBLING)
  if RUBY_PLATFORM =~ /x86_64-linux/i
  elsif RUBY_PLATFORM =~ /linux/i
    conf.cc.flags << %w(-msse2)
    conf.linker.flags << %w(-msse2)
  end

  #C compiler settings
  #conf.cc do |cc|
  #  cc.command = ENV['CC'] || 'gcc'
  #  cc.flags = [ENV['CFLAGS'] || %w()]
  #  cc.include_paths = ["#{root}/include"]
  #  cc.defines = %w(DISABLE_GEMS)
  #cc.option_include_path = '-IC:/cygdrive/e/cygwin/opt/gedi_v00_008_0004/include' || '-IC:/cygdrive/e/cygwin/opt/gnueabi/arm-brcm-linux-gnueabi/include' || '-IC:/cygdrive/c/cygwin64/home/joliveira/around_the_world/mruby/include'
  #  cc.option_define = '-D%s'
  #  cc.compile_options = "%{flags} -MMD -o %{outfile} -c %{infile}"
  #end

  # mrbc settings
  # conf.mrbc do |mrbc|
  #   mrbc.compile_options = "-g -B%{funcname} -o-" # The -g option is required for line numbers
  # end

  # Linker settings
  # conf.linker do |linker|
  #   linker.command = ENV['LD'] || 'gcc'
  #   linker.flags = [ENV['LDFLAGS'] || []]
  #   linker.flags_before_libraries = []
  #   linker.libraries = %w()
  #   linker.flags_after_libraries = []
  #   linker.library_paths = []
  #   linker.option_library = '-l%s'
  #   linker.option_library_path = '-L%s'
  #   linker.link_options = "%{flags} -o %{outfile} %{objs} %{libs}"
  # end

  # Archiver settings
  # conf.archiver do |archiver|
  #   archiver.command = ENV['AR'] || 'ar'
  #   archiver.archive_options = 'rs %{outfile} %{objs}'
  # end

  # Parser generator settings
  # conf.yacc do |yacc|
  #   yacc.command = ENV['YACC'] || 'bison'
  #   yacc.compile_options = '-o %{outfile} %{infile}'
  # end

  # gperf settings
  # conf.gperf do |gperf|
  #   gperf.command = 'gperf'
  #   gperf.compile_options = '-L ANSI-C -C -p -j1 -i 1 -g -o -t -N mrb_reserved_word -k"1,3,$" %{infile} > %{outfile}'
  # end

  # file extensions
  # conf.exts do |exts|
  #   exts.object = '.o'
  #   exts.executable = '' # '.exe' if Windows
  #   exts.library = '.a'
  # end

  # file separetor
  # conf.file_separator = '/'
end

# Define cross build settings
MRuby::CrossBuild.new('device') do |conf|
  toolchain :gcc_gertec
  
  enable_debug

  conf.bins = []
  conf.cc.defines << %w(SHA256_DIGEST_LENGTH=32 SHA512_DIGEST_LENGTH=64 MRB_STACK_EXTEND_DOUBLING)

  #if RUBY_PLATFORM =~ /x86_64-linux/i
  #elsif RUBY_PLATFORM =~ /linux/i
  #  conf.cc.flags << %w(-msse2)
  #  conf.linker.flags << %w(-msse2)
  #end

  conf.gembox File.join(AROUND_ROOT, "mrbgems", "around")
end

