%w{ bundler/setup rubygems fileutils uri net/http tmpdir digest/md5 ./doc/markit }.each do |file|
  require file
end

VERSION = '0.8-SNAPSHOT'
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
  patch_for_faster_require
  clone_repositories
  assemble_kitchen
end

def recreate_dirs
  FileUtils.rm_rf BUILD_DIR
  %w{ boxes docs home install repo tools }.each do |dir|
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
    %w{ cloud.github.com/downloads/adoxa/ansicon/ansi153.zip                                      ansicon },
    %w{ sourceforge.net/projects/console/files/console-devel/2.00/Console-2.00b148-Beta_32bit.zip console2 },
    %w{ www.holistech.co.uk/sw/hostsedit/hostsedit.zip                                            hostedit },
    %w{ c758482.r82.cf2.rackcdn.com/Sublime%20Text%202.0.1%20x64.zip                              sublimetext2 },
    %w{ msysgit.googlecode.com/files/PortableGit-1.7.10-preview20120409.7z                        portablegit },
    %w{ files.vagrantup.com/packages/eb590aa3d936ac71cbf9c64cf207f148ddfc000a/vagrant_1.0.3.msi   vagrant },
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
    system("#{BUILD_DIR}/set-env.bat \
      && gem uninstall vagrant -a -x -I \
      && gem install bundler -v 1.2.1 --no-ri --no-rdoc \
      && bundle install --gemfile=#{BUILD_DIR}/Gemfile --verbose")
  end
end

def patch_for_faster_require
  rubygems_rb = "#{BUILD_DIR}/tools/vagrant/vagrant/vagrant/embedded/lib/ruby/site_ruby/1.9.1/rubygems.rb"
  patch = <<-EOF
# Patch to make require faster on windows. Assumes that faster_require gem is installed
# and must be explicitly enabled by setting env var USE_FASTER_REQUIRE=TRUE
if (ENV['USE_FASTER_REQUIRE_GLOBALLY'] == 'TRUE')
  require File.expand_path('../../../gems/1.9.1/gems/faster_require-0.9.2/lib/faster_require.rb', __FILE__)
end
EOF
  prepend(patch, rubygems_rb)
  # the cache directory must be cleared after installing gems via bundler!
  FileUtils.rm_rf "#{BUILD_DIR}/home/.ruby_faster_require_cache"
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
    system("git clone git://github.com/#{repo} #{BUILD_DIR}/#{dest}")
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

def prepend(text, file)
  content = File.read(file)
  File.open(file, "w") do |f|
    f << text
    f << content
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
  uri = URI(url)
  Net::HTTP.start(uri.host, uri.port) do |http|
    http.request_get(uri.path + (uri.query ? "?#{uri.query}" : '')) do |response|
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
  when '.zip', '.7z'
    system("\"#{ZIP_EXE}\" x -o\"#{target_dir}\" -y \"#{archive}\" 1> NUL")
  when '.exe'
    system("\"#{ZIP_EXE}\" e -o\"#{target_dir}\" -y \"#{archive}\" -r #{includes.join(' ')} 1> NUL")
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