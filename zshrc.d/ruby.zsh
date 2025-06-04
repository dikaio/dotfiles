# ruby.zsh
# Ruby and Rails configuration

# Bundler aliases
alias b="bundle"
alias be="bundle exec"
alias bi="bundle install"
alias bu="bundle update"
alias bo="bundle open"

# Rails aliases
alias rc="rails console"
alias rs="rails server"
alias rg="rails generate"
alias rd="rails destroy"
alias rdb="rails db:migrate"
alias rdbr="rails db:rollback"
alias rr="rails routes"
alias rt="rails test"

# Rails migration helper
alias migrate="bin/rails db:migrate db:rollback && bin/rails db:migrate db:test:prepare"

# RSpec
alias s="rspec"
alias sf="rspec --fail-fast"

# Ruby version check
alias rv="ruby -v"

# Gem commands
alias gi="gem install"
alias gu="gem update"
alias gc="gem cleanup"