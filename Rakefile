%w{ bundler/setup yaml uri net/https tmpdir digest/md5 ./doc/markit }.each do |file|
  require file
end

# Immediately sync all stdout so that it's immediately visible, e.g. on appveyor
$stdout.sync = true
$stderr.sync = true

module EnvironmentOptions
  BASE_DIR = File.expand_path('.', File.dirname(__FILE__))
  VERSION = '3.1-SNAPSHOT'
  def version
    VERSION
  end
  def base_dir
    return BASE_DIR
  end
  def target_dir
    ddir=ENV["TARGET_DIR"]
    ddir||=File.join(base_dir,"target")
    File.expand_path(ddir)
  end
  def build_dir
    ddir=ENV["BUILD_DIR"]
    ddir||=File.join(target_dir,"build")
    File.expand_path(ddir)
  end
  def cache_dir
    ddir=ENV["CACHE_DIR"]
    ddir||=File.join(target_dir,"cache")
    File.expand_path(ddir)
  end
  def zip_exe
    zip=ENV["ZIP_EXE"]
    zip||='C:\Program Files\7-Zip\7z.exe'
    return File.expand_path(zip)
  end
end

include EnvironmentOptions

desc 'cleans the build output directory'
task :clean do
  purge_atom_plugins_with_insanely_long_path
  FileUtils.rm_rf build_dir, secure: true
end

desc 'wipes all output and cache directories'
task :wipe do
  purge_atom_plugins_with_insanely_long_path
  FileUtils.rm_rf target_dir, secure: true
end

desc 'downloads required resources and builds the devpack binary'
task :build => :clean do
  tools_config=YAML.load(File.read("#{base_dir}/config/tools.yaml"))
  recreate_dirs
  download_tools(tools_config)
  if tools_config.keys.include?("chefdk")
    move_chefdk
    fix_chefdk
  end
  copy_files
  generate_docs
  if tools_config.keys.include?("chefdk")
    install_knife_plugins(tools_config.fetch("chefdk",{}))
  end
  if tools_config.keys.include?("atom")
    install_atom_plugins(tools_config.fetch("atom",{}))
  end
  if tools_config.keys.include?("vagrant")
    install_vagrant_plugins(tools_config.fetch("vagrant",{}))
  end
  run_integration_tests
end

desc 'run integration tests'
task :test do
  run_integration_tests
end

desc 'run acceptance tests (WARNING: will download stuff, install gems, etc..)'
task :acceptance, [:provider] do |t, args|
  args.with_defaults :provider => 'virtualbox'
  run_acceptance_tests(args[:provider])
end

desc 'assemble `target/build` into a .7z package'
task :package do
  assemble_kitchen
end

# runs the install step with the given name (internal task for debugging)
task :run, [:method_name] do |t, args|
  self.send(args[:method_name].to_sym)
end

def run_integration_tests
  Bundler.with_clean_env do
    sh "rspec spec/integration -fd -c"
  end
end

def run_acceptance_tests(provider)
  Bundler.with_clean_env do
    FileUtils.rm_rf "#{build_dir}/repo/vagrant-workflow-tests"
    command = "#{build_dir}/set-env.bat \
        && cd #{build_dir}/repo \
        && git clone https://github.com/tknerr/vagrant-workflow-tests \
        && cd vagrant-workflow-tests \
        && #{acceptance_test_run_cmd(provider)}"
    fail "running acceptance tests failed" unless system(command)
  end
end

def acceptance_test_run_cmd(provider)
  case provider
  when 'virtualbox'
    "rspec"
  when 'docker'
    "b2d-start&& boot2docker config&& set VAGRANT_DEFAULT_PROVIDER=docker&& set KITCHEN_LOCAL_YAML=.kitchen.docker.yml&& rspec&& b2d-stop"
  else
    fail "unsupported provider for running the acceptance tests: #{provider}"
  end
end

def recreate_dirs
  %w{ home repo tools }.each do |dir|
    FileUtils.mkdir_p "#{build_dir}/#{dir}"
  end
  FileUtils.mkdir_p cache_dir
end

# use Windows builtin robocopy command to purge overly long paths,
# see https://blog.bertvanlangen.com/articles/path-too-long-use-robocopy/
def purge_atom_plugins_with_insanely_long_path
  empty_dir = "#{target_dir}/empty"
  atom_packages_dir = "#{build_dir}/home/.atom/packages"
  if File.exist?(atom_packages_dir)
    FileUtils.rm_rf empty_dir
    FileUtils.mkdir_p empty_dir
    sh "robocopy #{empty_dir} #{atom_packages_dir} /purge > NUL"
  end
end

def copy_files
  FileUtils.cp_r Dir.glob("#{base_dir}/files/*"), "#{build_dir}"
end

def generate_docs
  Dir.glob("#{base_dir}/*.md").each do |md_file|
    html = MarkIt.to_html(IO.read(md_file))
    outfile = "#{build_dir}/_#{File.basename(md_file, '.md')}.html"
    File.open(outfile, 'w') {|f| f.write(html) }
  end
end

def download_tools tools_config
  tools_config.each do |tname,cfg|
    download_and_unpack(cfg["url"], File.join(build_dir,'tools',tname), [])
  end
end

# move chef-dk to a shorter path to reduce the likeliness that a gem fails to install due to max path length
def move_chefdk
  FileUtils.mv "#{build_dir}/tools/chef_dk/opscode/chefdk", "#{build_dir}/tools/chefdk"
  #chefdk install package contains a zip file
  unpack("#{build_dir}/tools/chef_dk/opscode/chefdk.zip", "#{build_dir}/tools/chefdk")
  FileUtils.rm_rf "#{build_dir}/tools/chef_dk"
end

# ensure omnibus / chef-dk use the embedded ruby, see opscode/chef#1512
def fix_chefdk
  Dir.glob("#{build_dir}/tools/chefdk/bin/*").each do |file|
    if File.extname(file).empty? && File.exist?("#{file}.bat")  # do this only for the extensionless .bat counterparts
      File.write(file, File.read(file).gsub('#!C:/opscode/chefdk/embedded/bin/ruby.exe', '#!/usr/bin/env ruby'))
    end
  end
  Dir.glob("#{build_dir}/tools/chefdk/embedded/bin/*").each do |file|
    if File.extname(file).empty? && File.exist?("#{file}.bat")  # do this only for the extensionless .bat counterparts
      File.write(file, File.read(file).gsub('#!C:/opscode/chefdk/embedded/bin/ruby.exe', '#!/usr/bin/env ruby'))
    end
  end
  Dir.glob("#{build_dir}/tools/chefdk/embedded/bin/*.bat").each do |file|
    File.write(file, File.read(file).gsub('@"C:\opscode\chefdk\embedded\bin\ruby.exe" "%~dpn0" %*', '@"%~dp0ruby.exe" "%~dpn0" %*'))
  end
  Dir.glob("#{build_dir}/tools/chefdk/embedded/lib/ruby/gems/2.1.0/bin/*.bat").each do |file|
    File.write(file, File.read(file).gsub('@"C:\opscode\chefdk\embedded\bin\ruby.exe" "%~dpn0" %*', '@"%~dp0\..\..\..\..\..\bin\ruby.exe" "%~dpn0" %*'))
  end
end

def install_knife_plugins tool_config
  commands=["#{build_dir}/set-env.bat"]
  tool_config.fetch("plugins",{}).each do |plug,ver|
   commands<<"chef gem install #{plug} -v #{ver} --no-ri --no-rdoc"
  end
  Bundler.with_clean_env do
    command = commands.join(" && ")
    fail "knife plugin installation failed" unless system(command)
  end
end

def install_vagrant_plugins tool_config
  commands=["#{build_dir}/set-env.bat"]
  tool_config.fetch("plugins",{}).each do |plug,ver|
   commands<<"vagrant plugin install #{plug} --plugin-version #{ver}"
  end
  Bundler.with_clean_env do
    command = commands.join(" && ")
    fail "vagrant plugin installation failed" unless system(command)
  end
end

def install_atom_plugins tool_config
  commands=["#{build_dir}/set-env.bat"]
  commands+=tool_config.fetch("plugins",{}).keys.map do |plug|
    "apm install #{plug}"
  end
  Bundler.with_clean_env do
    command = commands.join(" && ")
    fail "atom plugins installation failed" unless system(command)
  end
end

def reset_git_user
  Bundler.with_clean_env do
    command = "#{build_dir}/set-env.bat \
      && git config --global --unset user.name \
      && git config --global --unset user.email"
    fail "resetting dummy git user failed" unless system(command)
  end
end

def pre_packaging_checks
  chefdk_gem_bindir = "#{build_dir}/home/.chefdk/gem/ruby/2.1.0/bin"
  unless Dir.glob("#{chefdk_gem_bindir}/*").empty?
    raise "beware: gem binaries in '#{chefdk_gem_bindir}' might use an absolute path to ruby.exe! Use `gem pristine` to fix it."
  end
end

def assemble_kitchen
  pre_packaging_checks
  reset_git_user
  pack build_dir, "#{target_dir}/bills-kitchen-#{VERSION}.7z"
end

def download_and_unpack(url, target_dir, includes = [])
  Dir.mktmpdir do |tmp_dir|
    outfile = "#{tmp_dir}/#{File.basename(url)}"
    download(url, outfile)
    if File.extname(target_dir).empty?
      unpack(outfile, target_dir, includes)
    else
      FileUtils.mkdir_p File.dirname(target_dir)
      FileUtils.cp outfile, target_dir
    end
  end
end

def download(url, outfile)
  puts "checking cache for '#{url}'"
  url_hash = Digest::MD5.hexdigest(url)
  cached_file = "#{cache_dir}/#{url_hash}"
  if File.exist? cached_file
    puts "cache-hit: read from '#{url_hash}'"
    FileUtils.cp cached_file, outfile
  else
    download_no_cache(url, outfile)
    puts "caching as '#{url_hash}'"
    FileUtils.cp outfile, cached_file
  end
end

def download_no_cache(url, outfile, limit=5)

  raise ArgumentError, 'HTTP redirect too deep' if limit == 0

  puts "download '#{url}'"
  uri = URI.parse url
  if ENV['HTTP_PROXY']
    proxy_host, proxy_port = ENV['HTTP_PROXY'].sub(/https?:\/\//, '').split ':'
    puts "using proxy #{proxy_host}:#{proxy_port}"
    http = Net::HTTP::Proxy(proxy_host, proxy_port.to_i).new uri.host, uri.port
  else
    http = Net::HTTP.new uri.host, uri.port
  end

  if uri.port == 443
    http.verify_mode = OpenSSL::SSL::VERIFY_NONE
    http.use_ssl = true
  end

  http.start do |agent|
    agent.request_get(uri.path + (uri.query ? "?#{uri.query}" : '')) do |response|
      # handle 301/302 redirects
      redirect_url = response['location']
      if(redirect_url)
        unless redirect_url.start_with? "http"
          redirect_url = "#{uri.scheme}://#{uri.host}:#{uri.port}#{redirect_url}"
        end
        puts "redirecting to #{redirect_url}"
        download_no_cache(redirect_url, outfile, limit - 1)
      else
        File.open(outfile, 'wb') do |f|
          response.read_body do |segment|
            f.write(segment)
          end
        end
      end
    end
  end
end

def unpack(archive, target_dir, includes = [])
  puts "extracting '#{archive}' to '#{target_dir}'"
  case File.extname(archive)
  when '.zip', '.7z', '.exe'
    system("\"#{zip_exe}\" x -o\"#{target_dir}\" -y \"#{archive}\" -r #{includes.join(' ')} 1> NUL")
  when '.msi'
    system("start /wait msiexec /a \"#{archive.gsub('/', '\\')}\" /qb TARGETDIR=\"#{target_dir.gsub('/', '\\')}\"")
  else
    raise "don't know how to unpack '#{archive}'"
  end
end

def pack(target_dir, archive)
  puts "packing '#{target_dir}' into '#{archive}'"
  Dir.chdir(target_dir) do
    system("\"#{zip_exe}\" a -t7z -y \"#{archive}\" \".\" 1> NUL")
  end
end

def release?
  !VERSION.end_with?('-SNAPSHOT')
end

def major_version
  VERSION.gsub(/^(\d+\.\d+).*$/, '\1')
end
