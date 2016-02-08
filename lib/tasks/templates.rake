namespace :templates do

  desc 'Compile all templates in app/views/templates to public/templates'
  task precompile: :environment do

    source = Rails.root.join 'client', 'index.html.slim'
    target = Rails.root.join 'public', 'index.html'

    contents = HomeController.new.render_to_string(
      :template => 'index',
      :locals => {  }
    )

    File.open(target, 'w'){ |f| f.write contents }

    puts Paint["Successfully generated #{target}", :green]
  end
end
