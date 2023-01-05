# R10k/Puppetfile Dependency Resolver

This tool takes a minimal `Puppetfile.src` as input and recursively resolves all
the dependencies into a final `Puppetfile` that r10k or other tools can use to
deploy your control repository.

This means that instead of listing every single Puppet module to be installed,
you can instead just list the modules that you actually care about and will use
directly. This has a few major benefits:

- It keeps your environment clean by automatically uninstalling modules that are
  no longer needed to match dependency requirements. It's far easier to track a
  short list of actively used modules and keep it current.
- It clarifies _intent_ so that you or future maintainers know which modules are
  expected to be actively used. Combined with [Dropsonde](https://dev.to/puppet/cleaning-up-unused-modules-with-dropsonde-44a5),
  to create module usage reports, it becomes much easier to clean up stale
  modules from your environment.
- It provides a _contract_ for your Puppet profile authors so they can know and
  trust which modules will be installed, even after future cleanups.

***Note:** if this [pull request](https://github.com/puppetlabs/r10k/pull/1314) is
merged and released, then it will obsolete this tool by incorporating the
functionality into r10k itself.*


## Installation

This is distributed as a Ruby gem. Simply install it with

```
gem install r10k-resolve
```


## Workflow

1. Write `Puppetfile.src` that describes only the modules you intend to use.
1. Run `r10k-resolve` from the same directory to generate the `Puppetfile` with
   all dependencies resolved.
     - You can also pass `--source` and `--output` arguments if you'd rather.
1. Review the generated `Puppetfile` for quality and security purposes. This is
   optional, but highly recommended.
1. Commit the `Puppetfile` and deploy your control repository, as fitting your
   standard workflow.

### Example `Puppetfile.src`

```ruby
mod 'dellemc-powerstore', '0.8.1'
mod 'puppetlabs-mysql', '13.1.0'
mod 'puppet-php', '8.1.1'
```

### Example generated `Puppetfile`

```ruby
mod 'dellemc-powerstore', '0.8.1'
mod 'puppetlabs-mysql', '13.1.0'
mod 'puppet-php', '8.1.1'

####### resolved dependencies #######
mod 'puppet-format', '1.0.0'
mod 'puppetlabs-stdlib', '8.5.0'
mod 'puppetlabs-apt', '8.5.0'
mod 'puppetlabs-inifile', '5.4.0'
mod 'puppet-zypprepo', '4.0.1'
mod 'puppet-archive', '6.1.0'
mod 'puppetlabs-concat', '7.3.0'

# Generated with r10k-resolve version 0.0.1
```

## Limitations

Note that all dependencies will be satisfied from the Forge, no matter what
the original source was. If you need a module version checked out from source
control, you'll either need to add that to the source `Puppetfile.src` or update
the generated `Puppetfile` to reflect this.


## Disclaimer

This is not yet rigorously tested. Please validate the generated output and make
sure it looks reasonable.
