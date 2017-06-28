require 'rubygems'
require 'rexml/document'
require 'pathname'
require 'etc'
include REXML

currentDirectory = Dir.pwd
projectFileName = Dir.glob("#{currentDirectory}/*.*proj")[0]
majorVersion = ARGV[0] || 1
minorVersion = ARGV[1] || 0
authors = Etc.getlogin
generateMachineKeys = false

# p ARGV, majorVersion, minorVersion, authors

unless projectFileName.nil?
  project = projectFileName.split('/').last
  projectName = File.basename(project, File.extname(project))
  # p projectName

  fileName = "#{currentDirectory}/#{projectName}.nuspec"

  isWebApplication = File.file?("web.config")
  isDotNetCoreApp = File.directory?("wwwroot")

  p isWebApplication, isDotNetCoreApp


  if(isDotNetCoreApp)
    projectDirectory = "#{currentDirectory}/bin/Release/netcoreapp1.1/publish"
  elsif(isWebApplication)
    projectDirectory = "#{currentDirectory}/obj/Release/Package/PackageTmp"
    webConfig = "#{currentDirectory}/Web.config"
  else
    projectDirectory = '{0}/bin/Release'
  end

  if(File.exist?(".git"))
    gitCommitCount = system( "git rev-list --all --count" )
    gitCommitCount = 0 if(gitCommitCount == NULL)
  else
    gitCommitCount = 0
  end

  version = "#{majorVersion}.#{minorVersion}.#{gitCommitCount}"

  p version

  formatter = REXML::Formatters::Pretty.new(2)
  formatter.compact = true # This is the magic line that does what you need!
  doc = Document.new
  # xmlwriter = doc.add_element
  xmlpackage = doc.add_element "package"
  xmlmetadata = xmlpackage.add_element "metadata"
  xmlid = xmlmetadata.add_element "id"
  xmlid.text = "#{projectName}"
  xmlversion = xmlmetadata.add_element "version"
  xmlversion.text = "#{version}"
  xmlversion = xmlmetadata.add_element "authors"
  xmlversion.text = "#{authors}"
  xmlversion = xmlmetadata.add_element "requireLicenseAcceptance"
  xmlversion.text = "false"
  xmlversion = xmlmetadata.add_element "description"
  xmlversion.text = "The #{projectName} deployment package, built on #{Time.now.strftime("%d/%m/%Y %H:%M")}"
  xmlversion = xmlmetadata.add_element "releaseNotes"
  xmlversion.text = "This pack is used to deploy #{projectName}"
  xmlversion = xmlmetadata.add_element "copyright"
  xmlversion.text = "copyright #{Time.now.strftime("%Y")}"

  xmlfiles = xmlpackage.add_element "files"

  Dir.glob("#{projectDirectory}/*") do |item|
    next if item == '.' or item == '..'
    xmlfile = xmlfiles.add_element "file"
    puts "item: #{item} File.directory?(item) : #{File.directory?("#{item}")}"
    if(File.directory?(item))
      xmlfile.attributes["src"] = "#{projectDirectory}/#{item}/**"
      xmlfile.attributes["target"] = "#{item}"
    else
      xmlfile.attributes["src"] = "#{projectDirectory}/#{item}"
      xmlfile.attributes["target"] = "."
    end
  end
  #xmlwriter.elements << xmlid
  #xmlwriter.text = "Hello World"

  File.open('/Users/h0n0032/Documents/himanshu/code/nuspec.nuspec', 'w') {|f| f.puts formatter.write(doc.root, "") }
end

item = "/Users/h0n0032/Projects/MyFirstApplication/MyFirstApplication/bin/Release/netcoreapp1.1/publish/"
#puts "item: #{item} File.directory?(item) : #{Dir.entries(item)}"
