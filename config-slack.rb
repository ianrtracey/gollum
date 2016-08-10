# Example gollum config with omnigollum authentication
# gollum ../wiki --config config.rb
#
# or run from source with
#
# bundle exec bin/gollum ../wiki/ --config config.rb

# Remove const to avoid
# warning: already initialized constant FORMAT_NAMES
#
# only remove if it's defined.
# constant Gollum::Page::FORMAT_NAMES not defined (NameError)
Gollum::Page.send :remove_const, :FORMAT_NAMES if defined? Gollum::Page::FORMAT_NAMES
# limit to one format
Gollum::Page::FORMAT_NAMES = { :markdown  => "Markdown" }

=begin
Valid formats are:
{ :markdown  => "Markdown",
  :textile   => "Textile",
  :rdoc      => "RDoc",
  :org       => "Org-mode",
  :creole    => "Creole",
  :rest      => "reStructuredText",
  :asciidoc  => "AsciiDoc",
  :mediawiki => "MediaWiki",
  :pod       => "Pod" }
=end

# Specify the path to the Wiki.
gollum_path = './'
Precious::App.set(:gollum_path, gollum_path)

# Specify the wiki options.
wiki_options = {
  :live_preview => false,
  :allow_uploads => true,
  :allow_editing => true
}
Precious::App.set(:wiki_options, wiki_options)

# Set as Sinatra environment as production (no stack traces)
Precious::App.set(:environment, :production)

# Setup Omniauth via Omnigollum.
require 'omnigollum'
require 'omniauth-github'
require 'omniauth-slack_signin'

options = {
  :providers => Proc.new do
    provider :slack_signin,
    ENV['HACK_ARIZONA_WIKI_SLACK_CLIENT_ID'],
    ENV['HACK_ARIZONA_WIKI_SLACK_CLIENT_SECRET'],
    scope: 'identity.basic, identity.email',
    team: ENV['HACK_ARIZONA_SLACK_TEAM_ID']
  end,
  :dummy_auth => false,
  # Make the entire wiki private
  :protected_routes => ['/*'],
  # Specify committer name as just the user name
  :author_format => Proc.new { |u| u.name },
  # Specify committer e-mail as just the user e-mail
  :author_email => Proc.new { |u| u.email },
  :default_name => "Anonymous",
  :default_email => "team@hackarizona.org",
  :authorized_users => ['team@hackarizona.org'],
}

# :omnigollum options *must* be set before the Omnigollum extension is registered
Precious::App.set(:omnigollum, options)
Precious::App.register Omnigollum::Sinatra
