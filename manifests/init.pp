class awsshell {
  include python

  python::pip { 'aws-shell':
   virtualenv => '/opt/boxen/homebrew',
  }

}
