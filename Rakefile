%w{ bundler/setup rubygems fileutils uri net/https tmpdir digest/md5 ./doc/markit }.each do |file|
  require file
end

VERSION = '2.4-SNAPSHOT'
BASE_DIR = File.expand_path('.', File.dirname(__FILE__)) 
TARGET_DIR  = "#{BASE_DIR}/target" 
BUILD_DIR   = "#{BASE_DIR}/target/build"
CACHE_DIR   = "#{BASE_DIR}/target/cache"
ZIP_EXE = 'C:\Program Files\7-Zip\7z.exe'


desc 'cleans all output and cache directories'
task :clean do 
  FileUtils.rm_rf TARGET_DIR
end

desc 'downloads required resources and builds the devpack binary'
task :build do
  recreate_dirs
  download_tools
  move_chefdk
  fix_chefdk
  copy_files
  generate_docs
  install_knife_plugins
  install_vagrant_plugins
  install_sublime_packagecontrol
  run_integration_tests
end

desc 'run integration tests'
task :test do
  run_integration_tests
end

desc 'run acceptance tests (WARNING: will download stuff, install gems, etc..)'
task :acceptance do
  run_acceptance_tests
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

def run_acceptance_tests
  Bundler.with_clean_env do
    FileUtils.rm_rf "#{BUILD_DIR}/repo/vagrant-workflow-tests"
    command = "#{BUILD_DIR}/set-env.bat \
        && cd #{BUILD_DIR}/repo \
        && git clone https://github.com/tknerr/vagrant-workflow-tests \
        && cd vagrant-workflow-tests \
        && rspec"
    fail "running acceptance tests failed" unless system(command)
  end
end

def recreate_dirs
  FileUtils.rm_rf BUILD_DIR
  %w{ home repo tools }.each do |dir|
    FileUtils.mkdir_p "#{BUILD_DIR}/#{dir}"
  end
  FileUtils.mkdir_p CACHE_DIR
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
    %w{ switch.dl.sourceforge.net/project/conemu/Preview/ConEmuPack.141110.7z                               conemu },
    %w{ github.com/mridgers/clink/releases/download/0.4.2/clink_0.4.2_setup.exe                             clink },
    %w{ c758482.r82.cf2.rackcdn.com/Sublime%20Text%202.0.2.zip                                              sublimetext2 },
    %w{ github.com/msysgit/msysgit/releases/download/Git-1.9.5-preview20141217/PortableGit-1.9.5-preview20141217.7z   portablegit },
    %w{ cdn.rubyinstaller.org/archives/devkits/DevKit-mingw64-32-4.7.2-20130224-1151-sfx.exe                devkit },
    %w{ switch.dl.sourceforge.net/project/kdiff3/kdiff3/0.9.96/KDiff3Setup_0.9.96.exe                       kdiff3
        kdiff3.exe },
    %w{ the.earth.li/~sgtatham/putty/0.63/x86/putty.zip                                                     putty },
    %w{ dl.bintray.com/mitchellh/vagrant/vagrant_1.7.2.msi                                                  vagrant },
    %w{ dl.bintray.com/mitchellh/terraform/terraform_0.3.6_windows_amd64.zip                                terraform },
    %w{ dl.bintray.com/mitchellh/packer/packer_0.7.5_windows_amd64.zip                                      packer },
    %w{ dl.bintray.com/mitchellh/consul/0.4.1_windows_386.zip                                               consul },
    %w{ opscode-omnibus-packages.s3.amazonaws.com/windows/2008r2/x86_64/chefdk-0.3.6-1.msi                  chef-dk }
  ]
  .each do |host_and_path, target_dir, includes = ''|
    download_and_unpack "http://#{host_and_path}", "#{BUILD_DIR}/tools/#{target_dir}", includes.split('|')    
  end
end

# move chef-dk to a shorter path to reduce the likeliness that a gem fails to install due to max path length
def move_chefdk
  FileUtils.mv "#{BUILD_DIR}/tools/chef-dk/opscode/chefdk", "#{BUILD_DIR}/tools/chefdk"
  FileUtils.rm_rf "#{BUILD_DIR}/tools/chef-dk"
end

def fix_chefdk
  Dir.glob("#{BUILD_DIR}/tools/chefdk/embedded/bin/*.bat").each do |file|
    # ensure omnibus / chef-dk use the embedded ruby, see opscode/chef#1512
    File.write(file, File.read(file).gsub('@"C:\opscode\chefdk\embedded\bin\ruby.exe" "%~dpn0" %*', '@"%~dp0ruby.exe" "%~dpn0" %*'))
  end
  # XXX: why are these .bat files even in there? -- the gem .bats should be in embedded/bin
  Dir.glob("#{BUILD_DIR}/tools/chefdk/embedded/lib/ruby/gems/2.0.0/bin/*.bat").each do |file|
    # ensure omnibus / chef-dk use the embedded ruby, see opscode/chef#1512
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
    && vagrant plugin install vagrant-toplevel-cookbooks --plugin-version 0.2.3 \
    && vagrant plugin install vagrant-omnibus --plugin-version 1.4.1 \
    && vagrant plugin install vagrant-cachier --plugin-version 1.2.0 \
    && vagrant plugin install vagrant-berkshelf --plugin-version 4.0.2"
    fail "vagrant plugin installation failed" unless system(command)
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
  chefdk_gem_bindir = "#{BUILD_DIR}/home/.chefdk/gem/ruby/2.0.0/bin"
  if not Dir[chefdk_gem_bindir].empty?
    raise "beware: gem binaries in '#{chefdk_gem_bindir}' might use an absolute path to ruby.exe!"
  end 
end

def install_sublime_packagecontrol
  target_dir = "#{BUILD_DIR}/tools/sublimetext2/Data/Installed Packages"
  FileUtils.mkdir_p target_dir
  # see also: files/tools/sublimetext2/Data/Packages/User/Package Control.sublime-settings
  download "https://sublime.wbond.net/Package%20Control.sublime-package", 
    "#{target_dir}/Package Control.sublime-package"
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
    unpack(outfile, target_dir, includes)
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
  system("cd #{target_dir} && \"#{ZIP_EXE}\" a -t7z -y \"#{archive}\" \".\" 1> NUL && cd ..")
end

def release?
  !VERSION.end_with?('-SNAPSHOT')
end

def major_version
  VERSION.gsub(/^(\d+\.\d+).*$/, '\1')
end
