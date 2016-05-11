%w{ bundler/setup rubygems fileutils uri net/https tmpdir digest/md5 ./doc/markit }.each do |file|
  require file
end

# Immediately sync all stdout so that it's immediately visible, e.g. on appveyor
$stdout.sync = true
$stderr.sync = true

VERSION = '3.1-SNAPSHOT'
BASE_DIR = File.expand_path('.', File.dirname(__FILE__))
TARGET_DIR  = "#{BASE_DIR}/target"
BUILD_DIR   = "#{BASE_DIR}/target/build"
CACHE_DIR   = "#{BASE_DIR}/target/cache"
ZIP_EXE = 'C:\Program Files\7-Zip\7z.exe'


desc 'cleans the build output directory'
task :clean do
  purge_atom_plugins_with_insanely_long_path
  FileUtils.rm_rf BUILD_DIR, secure: true
end

desc 'wipes all output and cache directories'
task :wipe do
  purge_atom_plugins_with_insanely_long_path
  FileUtils.rm_rf TARGET_DIR, secure: true
end

desc 'downloads required resources and builds the devpack binary'
task :build => :clean do
  recreate_dirs
  download_tools
  move_chefdk
  fix_chefdk
  copy_files
  generate_docs
  install_knife_plugins
  install_vagrant_plugins
  install_atom_plugins
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
    FileUtils.rm_rf "#{BUILD_DIR}/repo/vagrant-workflow-tests"
    command = "#{BUILD_DIR}/set-env.bat \
        && cd #{BUILD_DIR}/repo \
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
    FileUtils.mkdir_p "#{BUILD_DIR}/#{dir}"
  end
  FileUtils.mkdir_p CACHE_DIR
end

# use Windows builtin robocopy command to purge overly long paths,
# see https://blog.bertvanlangen.com/articles/path-too-long-use-robocopy/
def purge_atom_plugins_with_insanely_long_path
  empty_dir = "#{TARGET_DIR}/empty"
  atom_packages_dir = "#{BUILD_DIR}/home/.atom/packages"
  if File.exist?(atom_packages_dir)
    FileUtils.rm_rf empty_dir
    FileUtils.mkdir_p empty_dir
    sh "robocopy #{empty_dir} #{atom_packages_dir} /purge > NUL"
  end
end

def copy_files
  FileUtils.cp_r Dir.glob("#{BASE_DIR}/files/*"), "#{BUILD_DIR}"
end

def generate_docs
  Dir.glob("#{BASE_DIR}/*.md").each do |md_file|
    html = MarkIt.to_html(IO.read(md_file))
    outfile = "#{BUILD_DIR}/_#{File.basename(md_file, '.md')}.html"
    File.open(outfile, 'w') {|f| f.write(html) }
  end
end

def download_tools
  [
    %w{ github.com/boot2docker/boot2docker-cli/releases/download/v1.7.1/boot2docker-v1.7.1-windows-amd64.exe  docker/boot2docker.exe },
    %w{ github.com/docker/machine/releases/download/v0.4.0-rc2/docker-machine_windows-amd64.exe               docker/docker-machine.exe },
    %w{ get.docker.com/builds/Windows/x86_64/docker-1.7.1.exe                                                 docker/docker.exe },
    %w{ github.com/Maximus5/ConEmu/releases/download/v16.03.01/ConEmuPack.160301.7z                         conemu },
    %w{ github.com/mridgers/clink/releases/download/0.4.4/clink_0.4.4_setup.exe                             clink },
    %w{ github.com/atom/atom/releases/download/v1.7.3/atom-windows.zip                                      atom },
    %w{ github.com/git-for-windows/git/releases/download/v2.8.2.windows.1/PortableGit-2.8.2-64-bit.7z.exe   portablegit },
    %w{ cdn.rubyinstaller.org/archives/devkits/DevKit-mingw64-32-4.7.2-20130224-1151-sfx.exe                devkit },
    %w{ downloads.sourceforge.net/project/kdiff3/kdiff3/0.9.96/KDiff3Setup_0.9.96.exe                       kdiff3
        kdiff3.exe },
    %w{ the.earth.li/~sgtatham/putty/0.63/x86/putty.zip                                                     putty },
    %w{ www.itefix.net/dl/cwRsync_5.4.1_x86_Free.zip                                                        cwrsync },
    %w{ releases.hashicorp.com/vagrant/1.8.1/vagrant_1.8.1.msi                                              vagrant },
    %w{ releases.hashicorp.com/terraform/0.6.16/terraform_0.6.16_windows_amd64.zip                          terraform },
    %w{ releases.hashicorp.com/packer/0.10.1/packer_0.10.1_windows_amd64.zip                                packer },
    %w{ releases.hashicorp.com/consul/0.6.4/consul_0.6.4_windows_amd64.zip                                  consul },
    %w{ packages.chef.io/stable/windows/2008r2/chefdk-0.13.21-1-x86.msi                                     cdk }
  ]
  .each do |host_and_path, target_dir, includes = ''|
    target = "#{BUILD_DIR}/tools/#{target_dir}"
    if !File.exist? target
      download_and_unpack "http://#{host_and_path}", target, includes.split('|')
    end
  end
end

# move chef-dk to a shorter path to reduce the likeliness that a gem fails to install due to max path length
def move_chefdk
  FileUtils.mv "#{BUILD_DIR}/tools/cdk/opscode/chefdk", "#{BUILD_DIR}/tools/chefdk"
  # chefdk requires a two step install
  unpack "#{BUILD_DIR}/tools/cdk/opscode/chefdk.zip", "#{BUILD_DIR}/tools/chefdk"
  FileUtils.rm_rf "#{BUILD_DIR}/tools/cdk"
end

# ensure omnibus / chef-dk use the embedded ruby, see opscode/chef#1512
def fix_chefdk
  Dir.glob("#{BUILD_DIR}/tools/chefdk/bin/*").each do |file|
    if File.extname(file).empty? && File.exist?("#{file}.bat")  # do this only for the extensionless .bat counterparts
      File.write(file, File.read(file).gsub('#!C:/opscode/chefdk/embedded/bin/ruby.exe', '#!/usr/bin/env ruby'))
    end
  end
  Dir.glob("#{BUILD_DIR}/tools/chefdk/embedded/bin/*").each do |file|
    if File.extname(file).empty? && File.exist?("#{file}.bat")  # do this only for the extensionless .bat counterparts
      File.write(file, File.read(file).gsub('#!C:/opscode/chefdk/embedded/bin/ruby.exe', '#!/usr/bin/env ruby'))
    end
  end
  Dir.glob("#{BUILD_DIR}/tools/chefdk/embedded/bin/*.bat").each do |file|
    File.write(file, File.read(file).gsub('@"C:\opscode\chefdk\embedded\bin\ruby.exe" "%~dpn0" %*', '@"%~dp0ruby.exe" "%~dpn0" %*'))
  end
  Dir.glob("#{BUILD_DIR}/tools/chefdk/embedded/lib/ruby/gems/2.1.0/bin/*.bat").each do |file|
    File.write(file, File.read(file).gsub('@"C:\opscode\chefdk\embedded\bin\ruby.exe" "%~dpn0" %*', '@"%~dp0\..\..\..\..\..\bin\ruby.exe" "%~dpn0" %*'))
  end
end

def install_knife_plugins
  Bundler.with_clean_env do
    command = "#{BUILD_DIR}/set-env.bat \
    && chef gem install knife-audit -v 0.2.0 --no-ri --no-rdoc \
    && chef gem install knife-server -v 1.1.0 --no-ri --no-rdoc"
    fail "knife plugin installation failed" unless system(command)
  end
end

def install_vagrant_plugins
  Bundler.with_clean_env do
    command = "#{BUILD_DIR}/set-env.bat \
    && vagrant plugin install vagrant-toplevel-cookbooks --plugin-version 0.2.4 \
    && vagrant plugin install vagrant-omnibus --plugin-version 1.4.1 \
    && vagrant plugin install vagrant-cachier --plugin-version 1.2.1 \
    && vagrant plugin install vagrant-proxyconf --plugin-version 1.5.2 \
    && vagrant plugin install vagrant-berkshelf --plugin-version 4.1.0 \
    && vagrant plugin install vagrant-winrm --plugin-version 0.7.0"
    fail "vagrant plugin installation failed" unless system(command)
  end
end

def install_atom_plugins
  Bundler.with_clean_env do
    command = "#{BUILD_DIR}/set-env.bat \
    && apm install atom-beautify \
    && apm install minimap \
    && apm install line-ending-converter \
    && apm install language-chef \
    && apm install language-batchfile"
    fail "atom plugins installation failed" unless system(command)
  end
end

def reset_git_user
  Bundler.with_clean_env do
    command = "#{BUILD_DIR}/set-env.bat \
      && git config --global --unset user.name \
      && git config --global --unset user.email"
    fail "resetting dummy git user failed" unless system(command)
  end
end

def pre_packaging_checks
  chefdk_gem_bindir = "#{BUILD_DIR}/home/.chefdk/gem/ruby/2.1.0/bin"
  unless Dir.glob("#{chefdk_gem_bindir}/*").empty?
    raise "beware: gem binaries in '#{chefdk_gem_bindir}' might use an absolute path to ruby.exe! Use `gem pristine` to fix it."
  end
end

def assemble_kitchen
  pre_packaging_checks
  reset_git_user
  pack BUILD_DIR, "#{TARGET_DIR}/bills-kitchen-#{VERSION}.7z"
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
  cached_file = "#{CACHE_DIR}/#{url_hash}"
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
    system("\"#{ZIP_EXE}\" x -o\"#{target_dir}\" -y \"#{archive}\" -r #{includes.join(' ')} 1> NUL")
  when '.msi'
    system("start /wait msiexec /a \"#{archive.gsub('/', '\\')}\" /qb TARGETDIR=\"#{target_dir.gsub('/', '\\')}\"")
  else
    raise "don't know how to unpack '#{archive}'"
  end
end

def pack(target_dir, archive)
  puts "packing '#{target_dir}' into '#{archive}'"
  Dir.chdir(target_dir) do
    system("\"#{ZIP_EXE}\" a -t7z -y \"#{archive}\" \".\" 1> NUL")
  end
end

def release?
  !VERSION.end_with?('-SNAPSHOT')
end

def major_version
  VERSION.gsub(/^(\d+\.\d+).*$/, '\1')
end
