module ApplicationTemplateUtils
  def generate_template_scripts

    template_paths = Dir.glob Rails.root.join('client', '**', '*.html.slim')

    templates = template_paths.collect do |path|
      scope = Object.new
      options = {}
      rendered = Slim::Template.new(path, options).render(scope)

      {
        source: path,
        id: File.join('/templates', Pathname.new(path).relative_path_from(Rails.root.join('client')).to_s.sub(/\.slim$/, '')),
        contents: rendered
      }
    end
  end
end
