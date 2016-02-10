namespace :templates do

  desc 'Compile templates in client to public'
  task precompile: :environment do

    # At this time, templates are automatically precompiled into client/templates.js.erb
    # and served with application.js. This task only compiles client/index.html.slim into
    # public/index.html.
    source = Rails.root.join 'client', 'index.html.slim'
    target = Rails.root.join 'public', 'index.html'

    locals = {}
    contents = HomeController.new.render_to_string(template: 'index', locals: locals)

    File.open(target, 'w'){ |f| f.write contents }

    puts Paint["Successfully generated #{target}", :green]
  end
end
