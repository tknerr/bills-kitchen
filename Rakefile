%w{ bundler/setup rubygems fileutils uri net/https tmpdir digest/md5 ./doc/markit }.each do |file|
  require file
end

VERSION = '0.9-SNAPSHOT'
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
  # download_boxes
  download_installables
  copy_files
  generate_docs
  install_gems
  clone_repositories
  assemble_kitchen
end

desc 'creates a backup of the target/build directory'
task :backup do
  backup_target_build_dir
end

desc 'run integration tests (on travis)'
task :integration_test do
  Bundler.with_clean_env do
    unless system("bundle install --gemfile=files/Gemfile --verbose")
      fail "Could not install Bill's Kitchen gems specified in files/Gemfile"
    end
  end
end

def recreate_dirs
  FileUtils.rm_rf BUILD_DIR
  %w{ boxes docs home install repo tools }.each do |dir|
    FileUtils.mkdir_p "#{BUILD_DIR}/#{dir}"
  end
  FileUtils.mkdir_p CACHE_DIR
end

def backup_target_build_dir
  # create sequential backup of build directory if it exists
  unless Dir.exists? BUILD_DIR
    puts "nothing to back up"
    return
  end

  # unmount the W drive so we can take a backup
  w_mounted = Dir.exists? "W:/"
  if w_mounted
    puts "Unmounting W: so that a backup of your existing build directory can be created!"
    `#{BASE_DIR}/files/unmount-w-drive.cmd` 
  end
  
  index = 0
  backup_dir = "#{BUILD_DIR}.bak.#{index}"
  while Dir.exists? backup_dir
    index = index + 1
    backup_dir = "#{BUILD_DIR}.bak.#{index}"
  end

  FileUtils.mv BUILD_DIR, backup_dir
  puts "A backup of your existing build directory can be found at #{File.expand_path(backup_dir)}"
rescue => ex
  `#{BASE_DIR}/files/mount-w-drive.cmd` if w_mounted

  $stderr.puts
  $stderr.puts "\t===================================================================================="
  $stderr.puts "\tError creating backup of #{File.expand_path(BUILD_DIR)} was encountered." 
  $stderr.puts "\tPlease check that all of your vagrant boxes are shutdown "
  $stderr.puts "\tand that no open programs are using files on the W: drive or the path above."
  $stderr.puts
  $stderr.puts "\tIf the problem continues please download Unlocker from the link below"
  $stderr.puts "\thttp://usfiles.brothersoft.com/utilities/system_utilities/unlocker1.9.0-portable.zip"
  $stderr.puts "\tthis program will help you determine and fix what program still has flies open"
  $stderr.puts "\t===================================================================================="
  $stderr.puts
  raise ex  
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
    %w{ conemu-maximus5.googlecode.com/files/ConEmuPack.130220.7z                                 conemu },
    %w{ www.holistech.co.uk/sw/hostsedit/hostsedit.zip                                            hostedit },
    %w{ c758482.r82.cf2.rackcdn.com/Sublime%20Text%202.0.1%20x64.zip                              sublimetext2 },
    %w{ msysgit.googlecode.com/files/PortableGit-1.8.1.2-preview20130201.7z                       portablegit },
    %w{ rubyforge.org/frs/download.php/76799/ruby-1.9.3-p392-i386-mingw32.7z                      ruby },
    %w{ rubyforge.org/frs/download.php/76805/DevKit-mingw64-64-4.7.2-20130224-1432-sfx.exe        devkit },
    %w{ switch.dl.sourceforge.net/project/kdiff3/kdiff3/0.9.96/KDiff3Setup_0.9.96.exe             kdiff3 
        kdiff3.exe },
    %w{ the.earth.li/~sgtatham/putty/0.62/x86/putty.zip                                           putty }
  ]
  .each do |host_and_path, target_dir, includes = ''|
    download_and_unpack "http://#{host_and_path}", "#{BUILD_DIR}/tools/#{target_dir}", includes.split('|')    
  end
end

def download_boxes
  %w{ 
    ubuntu-12.04-server-amd64-bare-os.box 
    ubuntu-12.04-server-amd64-vagrant.box
  }
  .each do |file|
    download "http://dl.dropbox.com/u/13494216/#{file}.box", "#{BUILD_DIR}/boxes/#{file}.box"   
  end
end

def download_installables
  %w{ 
    www.gringod.com/wp-upload/MONACO.TTF
  }
  .each do |host_and_path|
    download "http://#{host_and_path}", "#{BUILD_DIR}/install/#{File.basename(host_and_path)}"
  end
end

def install_gems
  Bundler.with_clean_env do
    # XXX: DOH! - with_clean_env does not clear GEM_HOME if the rake task is invoked using `bundle exec`, 
    # which results in gems being installed to your current Ruby's GEM_HOME rather than Bills Kitchen's GEM_HOME!!! 
    fail "must run `rake build` instead of `bundle exec rake build`" if ENV['GEM_HOME']
    command = "#{BUILD_DIR}/set-env.bat \
      && git config --global --unset user.name \
      && git config --global --unset user.email \
      && gem install bundler -v 1.2.1 --no-ri --no-rdoc \
      && bundle install --gemfile=#{BUILD_DIR}/Gemfile --verbose"
    fail "gem installation failed" unless system(command)
  end
end

def clone_repositories
  [ 
    %w{ npverni/cucumber-sublime2-bundle.git  tools/sublimetext2/Data/Packages/Cucumber },
    %w{ cabeca/SublimeChef.git          tools/sublimetext2/Data/Packages/Chef },
    %w{ tknerr/bills-kitchen-repo.git       repo/my-chef-repo },
    %w{ tknerr/cookbooks-vagrant-ohai.git     repo/my-cookbooks/vagrant-ohai },
    %w{ tknerr/cookbooks-motd.git         repo/my-cookbooks/motd },
    %w{ tknerr/cookbooks-tdd-example.git    repo/my-cookbooks/tdd-example },
    %w{ tknerr/vagrant-baseboxes.git      repo/my-baseboxes }
  ]
  .each do |repo, dest|
    system("git clone https://github.com/#{repo} #{BUILD_DIR}/#{dest}")
    # for release check out branches as per https://gist.github.com/2928593
    if release? && repo.start_with?('tknerr/')
      system("cd #{BUILD_DIR}/#{dest} && git checkout -t origin/bills-kitchen-#{major_version}_branch")
    end
  end
end

def assemble_kitchen
  if release?
    pack BUILD_DIR, "#{TARGET_DIR}/bills-kitchen-#{VERSION}.7z"
  end
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
  system("\"#{ZIP_EXE}\" a -t7z -y \"#{archive}\" \"#{target_dir}\" 1> NUL")
end

def release?
  !VERSION.end_with?('-SNAPSHOT')
end

def major_version
  VERSION.gsub(/^(\d+\.\d+).*$/, '\1')
end
