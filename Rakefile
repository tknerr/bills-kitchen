require 'bundler/setup'
require 'rubygems'
require 'zip/zip'
require 'find'
require 'fileutils'
require 'uri'
require 'net/http'
require 'tmpdir'
require 'digest/md5'

VERSION = "0.4-SNAPSHOT"
SRC_DIR = File.expand_path("src", File.dirname(__FILE__))
BUILD_DIR = File.expand_path("out", File.dirname(__FILE__))
CACHE_DIR = File.expand_path("tmp", File.dirname(__FILE__))

desc "cleans the output and cache directories"
task :clean do
	FileUtils.rm_rf BUILD_DIR
	FileUtils.rm_rf CACHE_DIR
end

desc "downloads required resources and builds the devpack binary"
task :build do
	recreate_dirs
	copy_files
	download_tools
	# download_baseboxes
	# download_virtualbox
	create_gemfile
	install_gems
	#clone_repositories
	zip_devpack
end

def recreate_dirs
	FileUtils.rm_rf BUILD_DIR
	FileUtils.mkdir_p "#{BUILD_DIR}/boxes"
	FileUtils.mkdir_p "#{BUILD_DIR}/docs"
	FileUtils.mkdir_p "#{BUILD_DIR}/home"
	FileUtils.mkdir_p "#{BUILD_DIR}/install"
	FileUtils.mkdir_p "#{BUILD_DIR}/repo"
	FileUtils.mkdir_p "#{BUILD_DIR}/tools"
	# make sure cache dir exists
	FileUtils.mkdir_p CACHE_DIR
end

def copy_files
	FileUtils.cp_r Dir.glob("#{SRC_DIR}/*"), "#{BUILD_DIR}"
end

def download_tools
	download_extract_zip "http://cloud.github.com/downloads/adoxa/ansicon/ansi151.zip", 
		"#{BUILD_DIR}/tools/ansicon" 
	download_extract_zip "http://dfn.dl.sourceforge.net/project/console/console-devel/2.00/Console-2.00b148-Beta_32bit.zip", 
		"#{BUILD_DIR}/tools/console2"
	download_extract_zip "http://www.holistech.co.uk/sw/hostsedit/hostsedit.zip", 
		"#{BUILD_DIR}/tools/hostedit"
	download_extract_zip "http://c758482.r82.cf2.rackcdn.com/Sublime%20Text%202%20Build%202181%20x64.zip",
		"#{BUILD_DIR}/tools/sublimetext2"		
	download_extract_msi "http://files.vagrantup.com/packages/eb590aa3d936ac71cbf9c64cf207f148ddfc000a/vagrant_1.0.3.msi",
		"#{BUILD_DIR}/tools/vagrant"
end

def download_baseboxes
	download "http://dl.dropbox.com/u/13494216/chef-server-on-ubuntu-12.04-server-amd64-vagrant.box", 
		"#{BUILD_DIR}/boxes/chef-server-on-ubuntu-12.04-server-amd64-vagrant.box"
	download "http://dl.dropbox.com/u/13494216/ubuntu-12.04-server-amd64-bare-os.box",
		"#{BUILD_DIR}/boxes/ubuntu-12.04-server-amd64-bare-os.box"
	download "http://dl.dropbox.com/u/13494216/ubuntu-12.04-server-amd64-vagrant.box", 
		"#{BUILD_DIR}/boxes/ubuntu-12.04-server-amd64-vagrant.box" 
end

def download_virtualbox
	download "http://download.virtualbox.org/virtualbox/4.1.16/VirtualBox-4.1.16-78094-Win.exe", 
		"#{BUILD_DIR}/install/VirtualBox-4.1.16-78094-Win.exe"
end

def create_gemfile
	gem_file = <<GEMFILE
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

	File.open("#{BUILD_DIR}/Gemfile", 'w') { |f| f.write(gem_file) }
end

def install_gems
	Bundler.with_clean_env {
		system("#{BUILD_DIR}/set-env.bat \
			&& gem install bundler --no-ri --no-rdoc \
			&& bundle install --gemfile=#{BUILD_DIR}/Gemfile --verbose")
	}
end

def clone_repositories
	[ 
		['git://github.com/npverni/cucumber-sublime2-bundle.git', 	'tools/sublimetext2/Data/Packages/Cucumber'],
		['git://github.com/cabeca/SublimeChef.git', 				'tools/sublimetext2/Data/Packages/Chef'],
		['git://github.com/tknerr/chef-devpack-chef-repo.git', 		'repo/my-chef-repo'],
		['git://github.com/tknerr/vagrant-ohai.git', 				'repo/my-cookbooks/vagrant-ohai'],
		['git://github.com/tknerr/cookbooks-motd.git', 				'repo/my-cookbooks/motd'],
		['git://github.com/tknerr/vagrant-baseboxes.git', 			'repo/my-baseboxes']
	].each do | repo, dest |
		system("git clone #{repo} #{BUILD_DIR}/#{dest}")
	end
end

def download_extract_zip(url, target_dir)
	download_extract url, target_dir, :zip
end

def download_extract_msi(url, target_dir)
	download_extract url, target_dir, :msi
end

def download_extract(url, target_dir, type)	
	Dir.mktmpdir do |tmp| 
		outfile = "#{tmp}/out.zip"
		download(url, outfile)
		FileUtils.rm_rf target_dir
		case type
		when :zip; unpack_zip(outfile, target_dir)
		when :msi; unpack_msi(outfile, target_dir)
		end
	end
end

def download(url, outfile)
	puts "downloading '#{url}'"
	url_hash = Digest::MD5.hexdigest(url)
	cached_file = "#{CACHE_DIR}/#{url_hash}"
	if File.exist? cached_file
		puts "cache-hit: read from '#{url_hash}'"
		FileUtils.cp cached_file, outfile
	else
		uri = URI(url)
		Net::HTTP.start(uri.host, uri.port) do |http|
			f = open(outfile, 'wb')
			begin
				http.request_get(uri.path + (uri.query ? "?#{uri.query}" : "")) do |resp|
					resp.read_body do |segment|
						f.write(segment)
					end
				end
			ensure
				f.close()
			end
		end
		puts "caching as '#{url_hash}'"
		FileUtils.cp outfile, cached_file
	end
end

def unpack_zip(zip_file, target_dir)	
	puts "extracting zip file to '#{target_dir}'"		
	Zip::ZipFile.open(zip_file) do |file|
		file.each do |entry|
			target_path=File.join(target_dir, entry.name)
     		FileUtils.mkdir_p(File.dirname(target_path))	
     		file.extract(entry, target_path) unless File.exist?(target_path)
     	end
	end
end

def unpack_msi(msi_file, target_dir)
	puts "extracting msi file to '#{target_dir}'"		
	abs_msi_file = File.expand_path(msi_file).gsub('/', '\\')
	abs_target_dir = File.expand_path(target_dir).gsub('/', '\\')
	system("start /wait msiexec /a \"#{abs_msi_file}\" /qb TARGETDIR=\"#{abs_target_dir}\"")
	# TODO: remove intermediary files from msi
end

def zip_devpack
	target = "#{BUILD_DIR}/chef-devpack-#{VERSION}.zip"
	Zip::ZipFile.open(target, Zip::ZipFile::CREATE) do |zipfile|
		Find.find(BUILD_DIR) do |path|
			next if path == BUILD_DIR
			dest = path.sub /^#{BUILD_DIR}\//, ''
			zipfile.add(dest, path)
		end 
	end	
end
