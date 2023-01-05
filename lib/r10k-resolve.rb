require 'r10k-resolve/version'
require "puppetfile-resolver"
require "puppetfile-resolver/puppetfile/parser/r10k_eval"

class R10kResolve
  attr_accessor :source, :output, :force, :dryrun, :logger

  def initialize(options = {})
    [:source, :output, :force, :dryrun, :logger].each do |key|
      send("#{key}=", options[key])
    end

    @output = File.open(@output, 'w+') if @output.is_a? String
  end

  def resolve
    content = File.read(@source)
    puppetfile = PuppetfileResolver::Puppetfile::Parser::R10KEval.parse(content)

    # Make sure the Puppetfile is valid
    unless puppetfile.valid?
      logger.error("Puppetfile source is not valid")
      puppetfile.validation_errors.each { |err| logger.error(err) }
      return false
    end

    resolver = PuppetfileResolver::Resolver.new(puppetfile, nil)
    result = resolver.resolve(strict_mode: true)

    # Output resolution validation information
    result.validation_errors.each { |err| logger.info(err) }

    logger.info('Generating Puppetfile...')

    # copy over the existing Puppetfile, then add resolved dependencies below
    @output.write(puppetfile.content)
    @output.write("\n####### resolved dependencies #######\n")

    result.dependency_graph.each do |dep|
      # ignore the original modules, they're already in the output
      next if puppetfile.modules.find { |mod| mod.name == dep.name }

      mod = dep.payload
      next unless mod.is_a?(PuppetfileResolver::Models::ModuleSpecification)

      @output.write("mod '#{dep.payload.owner}-#{dep.payload.name}', '#{dep.payload.version}'\n")
    end

    @output.write("\n# Generated with r10k-resolve version #{R10kResolve::VERSION}\n\n")

    logger.warn(
      "Please inspect the output to ensure you know what you are deploying in your infrastructure."
    )
  end
end
