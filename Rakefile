%w{ bundler/setup rubygems fileutils uri net/http tmpdir digest/md5 }.each do |file|
	require file
end

VERSION = '0.4-SNAPSHOT'
BASE_DIR = File.expand_path('.', File.dirname(__FILE__)) 
SRC_DIR 	= "#{BASE_DIR}/src"
TARGET_DIR 	= "#{BASE_DIR}/target" 
BUILD_DIR 	= "#{BASE_DIR}/target/build"
CACHE_DIR 	= "#{BASE_DIR}/target/cache"
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
	install_gems
	clone_repositories
	bundle_devpack
end


def recreate_dirs
	FileUtils.rm_rf BUILD_DIR
	%w{ boxes docs home install repo tools }.each do |dir|
		FileUtils.mkdir_p "#{BUILD_DIR}/#{dir}"
	end
	FileUtils.mkdir_p CACHE_DIR
end

def copy_files
	FileUtils.cp_r Dir.glob("#{SRC_DIR}/*"), "#{BUILD_DIR}"
end

def download_tools
	[
		%w{ cloud.github.com/downloads/adoxa/ansicon/ansi151.zip 										ansicon },
		%w{ dfn.dl.sourceforge.net/project/console/console-devel/2.00/Console-2.00b148-Beta_32bit.zip 	console2 },
		%w{ www.holistech.co.uk/sw/hostsedit/hostsedit.zip 												hostedit },
		%w{ c758482.r82.cf2.rackcdn.com/Sublime%20Text%202%20Build%202181%20x64.zip 					sublimetext2 },
		%w{ msysgit.googlecode.com/files/PortableGit-1.7.10-preview20120409.7z							portablegit-1.7.10-preview },
		%w{ files.vagrantup.com/packages/eb590aa3d936ac71cbf9c64cf207f148ddfc000a/vagrant_1.0.3.msi 	vagrant },
		%w{ miked.ict.rave.ac.uk/download/attachments/589834/OpenSSH_for_Windows_5.6p1-2.exe 			sshwindows 
			ssh.exe|scp.exe|cygz.dll|cygwin1.dll|cygssp-0.dll|cyggcc_s-1.dll|cygcrypto-0.9.8.dll },
		%w{ switch.dl.sourceforge.net/project/kdiff3/kdiff3/0.9.96/KDiff3Setup_0.9.96.exe 				kdiff3 
			kdiff3.exe }
	]
	.each do |host_and_path, target_dir, includes = ''|
		download_and_unpack "http://#{host_and_path}", "#{BUILD_DIR}/tools/#{target_dir}", includes.split('|')		
	end
end

def download_boxes
	%w{ 
		ubuntu-12.04-server-amd64-bare-os.box 
		ubuntu-12.04-server-amd64-vagrant.box
		chef-server-on-ubuntu-12.04-server-amd64-vagrant
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
	gem_file = "#{BUILD_DIR}/Gemfile"

	File.open(gem_file, 'w') do |f| 
		f.write(<<-GEMFILE)
source 'http://rubygems.org'

# core gems we need for cookin'
gem 'vagrant', '1.0.2.patch1', :git => 'git://github.com/tknerr/vagrant.git', :branch => 'GH-247'	
gem 'chef', '0.10.10'
gem 'librarian', '0.0.20'

# gems we need for t[e|a]sting
gem 'foodcritic', '~>1.0.1'
gem 'chefspec', '~>0.5.0'
gem 'cucumber-nagios', '~>0.6.8'

# optional but useful (for dessert)
gem 'veewee', '0.3.0.alpha9'
gem 'sahara', '0.0.10.patch1', :git => 'git://github.com/tknerr/sahara.git'
GEMFILE
	end
	
	# need a clean env without bundler env vars
	Bundler.with_clean_env {
		system("#{BUILD_DIR}/set-env.bat \
			&& gem install bundler --no-ri --no-rdoc \
			&& bundle install --gemfile=#{gem_file} --verbose")
	}
end

def clone_repositories
	[ 
		%w{ npverni/cucumber-sublime2-bundle.git 	tools/sublimetext2/Data/Packages/Cucumber },
		%w{ cabeca/SublimeChef.git 					tools/sublimetext2/Data/Packages/Chef },
		%w{ tknerr/chef-devpack-chef-repo.git 		repo/my-chef-repo },
		%w{ tknerr/vagrant-ohai.git 				repo/my-cookbooks/vagrant-ohai },
		%w{ tknerr/cookbooks-motd.git 				repo/my-cookbooks/motd },
		%w{ tknerr/vagrant-baseboxes.git 			repo/my-baseboxes }
	]
	.each do |repo, dest|
		system("git clone git://github.com/#{repo} #{BUILD_DIR}/#{dest}")
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

def download_no_cache(url, outfile)
	puts "download '#{url}'"
	uri = URI(url)
	Net::HTTP.start(uri.host, uri.port) do |http|
		File.open(outfile, 'wb') do |f|
			http.request_get(uri.path + (uri.query ? "?#{uri.query}" : '')) do |resp|
				resp.read_body do |segment|
					f.write(segment)
				end
			end
		end
	end
end

def download_and_unpack(url, target_dir, includes = [])	
	Dir.mktmpdir do |tmp_dir| 
		outfile = "#{tmp_dir}/out.packed"
		download(url, outfile)
		unpack(outfile, target_dir, get_type(url), includes)
	end
end

def get_type(url)
	File.extname(url).slice(1..-1).to_sym
end

def unpack(archive, target_dir, type, includes = [])
	puts "extracting #{type} file to '#{target_dir}'"	
	case type
	when :zip, :'7z'
		system("\"#{ZIP_EXE}\" x -o\"#{target_dir}\" -y \"#{archive}\" 1> NUL")
	when :exe
		system("\"#{ZIP_EXE}\" e -o\"#{target_dir}\" -y \"#{archive}\" -r #{includes.join(' ')} 1> NUL")
	when :msi
		system("start /wait msiexec /a \"#{archive.gsub('/', '\\')}\" /qb TARGETDIR=\"#{target_dir.gsub('/', '\\')}\"")
	else 
		raise "don't know how to unpack #{type} file"
	end
end

def bundle_devpack
	archive = "#{TARGET_DIR}/chef-devpack-#{VERSION}.7z"
	puts "bundling devpack to '#{archive}'"
	system("\"#{ZIP_EXE}\" a -t7z -y \"#{archive}\" \"#{BUILD_DIR}\" 1> NUL")
end